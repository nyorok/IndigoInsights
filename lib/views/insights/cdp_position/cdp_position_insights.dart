import 'dart:developer'; // For log

import 'package:collection/collection.dart'; // For .firstWhereOrNull
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:indigo_insights/providers/asset_price_provider.dart';
import 'package:indigo_insights/providers/cdp_provider.dart';
import 'package:indigo_insights/utils/loader.dart';
import 'package:intl/intl.dart'; // For formatting numbers

// Helper functions for calculations using double
double calculateCollateralRatio(
  double collateralAmount,
  double mintedAmount,
  double iAssetPrice,
) {
  if (mintedAmount == 0 || iAssetPrice == 0) return double.infinity;
  final debtValue = mintedAmount * iAssetPrice;
  if (debtValue == 0) return double.infinity;
  return (collateralAmount / debtValue) * 100.0;
}

double calculateLTV(
  double collateralAmount,
  double mintedAmount,
  double iAssetPrice,
) {
  if (collateralAmount == 0) return 0.0;
  final debtValue = mintedAmount * iAssetPrice;
  return (debtValue / collateralAmount) * 100.0;
}

double calculateNetValue(
  double collateralAmount,
  double mintedAmount,
  double iAssetPrice,
) {
  final debtValue = mintedAmount * iAssetPrice;
  return collateralAmount - debtValue;
}

double calculateLiquidationPrice(
  double collateralAmount,
  double mintedAmount,
  double iAssetPrice,
  double liquidationRatio,
) {
  if (collateralAmount == 0) return double.infinity;
  final debtValue = mintedAmount * iAssetPrice;
  // Formula: Liquidation Price = (Debt Value * Liquidation Ratio) / Collateral Amount
  final liquidationPrice = (debtValue * liquidationRatio) / collateralAmount;
  return liquidationPrice;
}

class CdpPositionInsights extends HookConsumerWidget {
  const CdpPositionInsights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController addressController =
        TextEditingController(); // Local controller

    final userCdpsAsync = ref.watch(cdpsProvider);
    final assetPricesAsync = ref.watch(assetPricesProvider);

    //make it a flutter hooks state
    final userAddress = useState<String?>(null);

    const double adaLiquidationRatio = 2.0; // Example: 200% liquidation ratio

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address Input Field
          TextField(
            controller: addressController,
            decoration: InputDecoration(
              labelText: 'Enter your Cardano Address',
              hintText: 'addr1...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  // Trigger the fetch when the user presses the search button

                  userAddress.value =
                      "31161a3f479812bb1b676672d89d870a9eb53209c5ac33bec960388e";
                  // await ref.read(
                  //   fetchPaymentCredentialProvider(
                  //     address: addressController.text.trim(),
                  //   ).future,
                  // );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 24),

          if (userAddress.value == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Please enter your Cardano address and click "Check My Positions" to view your CDP positions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),

          if (userAddress.value != null)
            userCdpsAsync.when(
              loading: () => const Center(child: Loader()),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Error loading CDPs: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (cdps) {
                final userCdps = cdps
                    .where((cdp) => cdp.owner == userAddress.value)
                    .toList();

                if (userCdps.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No active CDPs found for this address. Please ensure the address is correct and has active CDPs.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active CDPs:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userCdps.length,
                        itemBuilder: (context, index) {
                          final cdp = userCdps[index];
                          final iAssetPrice =
                              assetPricesAsync.valueOrNull
                                  ?.firstWhereOrNull(
                                    (ap) => ap.asset == cdp.asset,
                                  )
                                  ?.price ??
                              0.0;

                          final cr = calculateCollateralRatio(
                            cdp.collateralAmount,
                            cdp.mintedAmount,
                            iAssetPrice,
                          );
                          final ltv = calculateLTV(
                            cdp.collateralAmount,
                            cdp.mintedAmount,
                            iAssetPrice,
                          );
                          final netValue = calculateNetValue(
                            cdp.collateralAmount,
                            cdp.mintedAmount,
                            iAssetPrice,
                          );
                          final liquidationPrice = calculateLiquidationPrice(
                            cdp.collateralAmount,
                            cdp.mintedAmount,
                            iAssetPrice,
                            adaLiquidationRatio,
                          );

                          Color crColor;
                          String crStatus;
                          if (cr >= 200) {
                            crColor = Colors.green[700]!;
                            crStatus = 'Healthy';
                          } else if (cr >= 185) {
                            crColor = Colors.orange[700]!;
                            crStatus = 'At Risk';
                          } else {
                            crColor = Colors.red[700]!;
                            crStatus = 'Critical';
                          }

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // CDP Type Header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'CDP: ${cdp.asset}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: crColor.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          crStatus,
                                          style: TextStyle(
                                            color: crColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Collateral and Minted Amounts
                                  _buildMetricRow(
                                    icon: Icons.account_balance_wallet,
                                    label: 'Collateral Deposited',
                                    value:
                                        '${NumberFormat.currency(symbol: '', decimalDigits: 0).format(cdp.collateralAmount)} ADA',
                                    subValue:
                                        '(\$${NumberFormat.currency(symbol: '', decimalDigits: 2).format(cdp.collateralAmount)})',
                                  ),
                                  _buildMetricRow(
                                    icon: Icons.paid,
                                    label: 'iAssets Minted',
                                    value:
                                        '${NumberFormat.currency(symbol: '', decimalDigits: 2).format(cdp.mintedAmount)} ${cdp.asset}',
                                    subValue:
                                        '(\$${NumberFormat.currency(symbol: '', decimalDigits: 2).format(cdp.mintedAmount * iAssetPrice)})',
                                  ),
                                  const Divider(height: 24),

                                  // Key Ratios
                                  _buildMetricRow(
                                    icon: Icons.safety_check,
                                    label: 'Collateral Ratio (CR)',
                                    value:
                                        '${NumberFormat.decimalPattern('en_US').format(cr)}%',
                                    valueColor: crColor,
                                  ),
                                  _buildMetricRow(
                                    icon: Icons.pie_chart,
                                    label: 'Loan-to-Value (LTV)',
                                    value:
                                        '${NumberFormat.decimalPattern('en_US').format(ltv)}%',
                                  ),
                                  _buildMetricRow(
                                    icon: Icons.savings,
                                    label: 'Net Value',
                                    value:
                                        '\$${NumberFormat.currency(symbol: '', decimalDigits: 2).format(netValue)}',
                                    valueColor: netValue >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  _buildMetricRow(
                                    icon: Icons.flash_on,
                                    label: 'Liquidation Price (ADA)',
                                    value:
                                        '\$${NumberFormat.currency(symbol: '', decimalDigits: 2).format(liquidationPrice)}',
                                  ),
                                  const SizedBox(height: 16),

                                  // Action Buttons (Placeholder)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            log(
                                              'Add collateral for ${cdp.asset}',
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Add collateral for ${cdp.asset}',
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add Collateral'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14)),
                Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (subValue != null)
                  Text(subValue, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
