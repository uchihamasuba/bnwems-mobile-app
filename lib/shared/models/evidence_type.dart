enum EvidenceType {
  survey,
  checkout,
  installation,
  handover,
  damageLoss,
  payment,
  warehouseReturn;

  String get displayName {
    switch (this) {
      case EvidenceType.survey:
        return 'Khảo sát';
      case EvidenceType.checkout:
        return 'Xuất kho';
      case EvidenceType.installation:
        return 'Lắp đặt/Thi công';
      case EvidenceType.handover:
        return 'Bàn giao';
      case EvidenceType.damageLoss:
        return 'Hư hỏng/Mất mát';
      case EvidenceType.payment:
        return 'Thanh toán';
      case EvidenceType.warehouseReturn:
        return 'Hoàn trả kho';
    }
  }

  static EvidenceType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'survey':
        return EvidenceType.survey;
      case 'checkout':
        return EvidenceType.checkout;
      case 'installation':
        return EvidenceType.installation;
      case 'handover':
        return EvidenceType.handover;
      case 'damage/loss':
      case 'damageloss':
      case 'damage_loss':
        return EvidenceType.damageLoss;
      case 'payment':
        return EvidenceType.payment;
      case 'return':
      case 'warehousereturn':
      case 'warehouse_return':
        return EvidenceType.warehouseReturn;
      default:
        return EvidenceType.survey;
    }
  }
}
