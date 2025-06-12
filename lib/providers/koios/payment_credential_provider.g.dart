// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_credential_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchPaymentCredentialHash() =>
    r'141a0492af5c4991eb8057f00a582577dd51ef89';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [fetchPaymentCredential].
@ProviderFor(fetchPaymentCredential)
const fetchPaymentCredentialProvider = FetchPaymentCredentialFamily();

/// See also [fetchPaymentCredential].
class FetchPaymentCredentialFamily extends Family<AsyncValue<String?>> {
  /// See also [fetchPaymentCredential].
  const FetchPaymentCredentialFamily();

  /// See also [fetchPaymentCredential].
  FetchPaymentCredentialProvider call({required String address}) {
    return FetchPaymentCredentialProvider(address: address);
  }

  @override
  FetchPaymentCredentialProvider getProviderOverride(
    covariant FetchPaymentCredentialProvider provider,
  ) {
    return call(address: provider.address);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fetchPaymentCredentialProvider';
}

/// See also [fetchPaymentCredential].
class FetchPaymentCredentialProvider
    extends AutoDisposeFutureProvider<String?> {
  /// See also [fetchPaymentCredential].
  FetchPaymentCredentialProvider({required String address})
    : this._internal(
        (ref) => fetchPaymentCredential(
          ref as FetchPaymentCredentialRef,
          address: address,
        ),
        from: fetchPaymentCredentialProvider,
        name: r'fetchPaymentCredentialProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fetchPaymentCredentialHash,
        dependencies: FetchPaymentCredentialFamily._dependencies,
        allTransitiveDependencies:
            FetchPaymentCredentialFamily._allTransitiveDependencies,
        address: address,
      );

  FetchPaymentCredentialProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.address,
  }) : super.internal();

  final String address;

  @override
  Override overrideWith(
    FutureOr<String?> Function(FetchPaymentCredentialRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchPaymentCredentialProvider._internal(
        (ref) => create(ref as FetchPaymentCredentialRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        address: address,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _FetchPaymentCredentialProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchPaymentCredentialProvider && other.address == address;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, address.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchPaymentCredentialRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `address` of this provider.
  String get address;
}

class _FetchPaymentCredentialProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with FetchPaymentCredentialRef {
  _FetchPaymentCredentialProviderElement(super.provider);

  @override
  String get address => (origin as FetchPaymentCredentialProvider).address;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
