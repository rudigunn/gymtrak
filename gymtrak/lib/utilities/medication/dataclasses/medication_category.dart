enum ComponentCategory {
  hormoneReplacementTherapy,
  aromataseInhibitor,
  supplement,
  sarms,
  pct,
  ancillary,
  other
}

class ComponentCategoryClass {
  static const Map<ComponentCategory, String> names = {
    ComponentCategory.hormoneReplacementTherapy: 'Hormone Replacement Therapy',
    ComponentCategory.aromataseInhibitor: 'Aromatase Inhibitor',
    ComponentCategory.supplement: 'Supplement',
    ComponentCategory.sarms: 'SARMs',
    ComponentCategory.pct: 'PCT',
    ComponentCategory.ancillary: 'Ancillary',
    ComponentCategory.other: 'Other',
  };

  static String getName(ComponentCategory type) => names[type]!;
}

final List<String> categories = [
  'Hormone Replacement Therapy',
  'Aromatase Inhibitor',
  'Supplement',
  'SARMs',
  'PCT',
  'Ancillary',
  'Other',
];
