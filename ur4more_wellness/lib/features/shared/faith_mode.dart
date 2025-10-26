enum FaithTier { off, light, disciple, kingdom }

extension FaithFlags on FaithTier {
  bool get isOff => this == FaithTier.off;
  bool get isActivated => this != FaithTier.off;
  bool get isDeep => this == FaithTier.disciple || this == FaithTier.kingdom;
}
