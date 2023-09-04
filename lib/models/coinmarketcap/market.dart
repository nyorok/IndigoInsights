class Market {
  final String exchangeName;
  final double liquidity;

  Market({required this.exchangeName, required this.liquidity});

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
        exchangeName: json['exchangeName'], liquidity: json['liquidity']);
  }
}
