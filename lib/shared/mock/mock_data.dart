import '../models/core_models.dart';
import '../models/user_role.dart';
import '../models/order_status.dart';
import '../models/payment_status.dart';
import '../models/evidence_type.dart';

class MockData {
  MockData._();

  // 1. App Users
  static const AppUser managerUser = AppUser(
    id: 'USR-MGR-001',
    fullName: 'Lê Nguyễn Hoàng',
    email: 'manager@test.com',
    role: UserRole.manager,
  );

  static const AppUser leaderUser = AppUser(
    id: 'USR-LDR-001',
    fullName: 'Phan Anh Tuấn',
    email: 'leader@test.com',
    role: UserRole.leader,
  );

  static const AppUser technicalUser = AppUser(
    id: 'USR-TEC-001',
    fullName: 'Nguyễn Văn Minh',
    email: 'technical@test.com',
    role: UserRole.technical,
  );

  // 2. Mock Notifications
  static final List<MobileNotification> notifications = [
    MobileNotification(
      id: 'NTF001',
      title: 'Thi công hiện trường bị trễ',
      orderCode: 'ORD-2026-001',
      message:
          'Tác vụ "Lắp đặt khung bạt chính tầng 5" quá hạn 2 tiếng chưa báo hoàn thành.',
      type: 'Field Operation',
      priority: 'High',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      targetRoute: '/manager-field-progress',
    ),
    MobileNotification(
      id: 'NTF002',
      title: 'Báo cáo khảo sát mới cần duyệt',
      orderCode: 'ORD-2026-002',
      message:
          'Leader Phan Anh Tuấn đã nộp báo cáo khảo sát hiện trường tại Riverside Palace.',
      type: 'Survey',
      priority: 'Medium',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      targetRoute: '/manager-survey-review',
    ),
    MobileNotification(
      id: 'NTF003',
      title: 'Yêu cầu đổi thiết bị hiện trường',
      orderCode: 'ORD-2026-001',
      message:
          'Leader đề xuất: Thêm 20 đèn LED 50W lối đi ngoài trời, phát sinh 2,000,000đ.',
      type: 'Change Request',
      priority: 'High',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      targetRoute: '/manager-change-request-approval',
    ),
    MobileNotification(
      id: 'NTF004',
      title: 'Xác nhận cọc tiền chờ duyệt',
      orderCode: 'ORD-2026-002',
      message:
          'Khách hàng Phạm Minh Tuấn đã tải lên minh chứng chuyển khoản cọc 30,000,000đ.',
      type: 'Payment',
      priority: 'High',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      targetRoute: '/manager-payment-confirmation',
    ),
    MobileNotification(
      id: 'NTF005',
      title: 'Báo cáo hỏng hóc vật tư',
      orderCode: 'ORD-2026-003',
      message:
          'Biên bản thu hồi ORD-003 phát hiện gãy 2 chân ghế Chiavari có nệm.',
      type: 'Damage/Loss',
      priority: 'Medium',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      targetRoute: '/order-detail',
    ),
  ];

  // 3. Mock Orders
  static final List<MobileOrder> orders = [
    MobileOrder(
      id: 'ORD-2026-001',
      orderCode: 'ORD-2026-001',
      customerName: 'Nguyễn Hoàng Nam & Lê Thị Mai',
      customerPhone: '0979112233',
      eventDateTime: DateTime(2026, 6, 25, 17, 30),
      location: 'Sân thượng Gem Center, 8 Nguyễn Bỉnh Khiêm, Q.1, TP.HCM',
      leaderStaffName: 'Phan Anh Tuấn',
      orderStatus: OrderStatus.executing,
      paymentStatus: PaymentStatus.partiallyPaid,
      surveyStatus: 'Approved',
      fieldProgressStatus: 'Installation',
      hasEmergency: true,
      urgencyMessage: 'Thiếu 20 đèn LED par chưa chuyển từ Kho Q7',
      totalAmount: 150000000,
      paidAmount: 50000000,
    ),
    MobileOrder(
      id: 'ORD-2026-002',
      orderCode: 'ORD-2026-002',
      customerName: 'Phạm Minh Tuấn & Trần Thuỳ Chi',
      customerPhone: '0988665544',
      eventDateTime: DateTime(2026, 7, 2, 11, 0),
      location: 'Riverside Palace, 360 Bến Vân Đồn, Quận 4, TP.HCM',
      leaderStaffName: 'Phan Anh Tuấn',
      orderStatus: OrderStatus.pendingDeposit,
      paymentStatus: PaymentStatus.unpaid,
      surveyStatus: 'Pending',
      fieldProgressStatus: 'Check-out',
      hasEmergency: true,
      urgencyMessage: 'Báo cáo khảo sát chờ duyệt & Đợi xác nhận tiền cọc',
      totalAmount: 85000000,
      paidAmount: 0,
    ),
    MobileOrder(
      id: 'ORD-2026-003',
      orderCode: 'ORD-2026-003',
      customerName: 'Hoàng Quốc Bảo & Vũ Mỹ Linh',
      customerPhone: '0903445566',
      eventDateTime: DateTime(2026, 6, 18, 18, 0),
      location: 'Sân golf Tân Sơn Nhất, Quận Tân Bình, TP.HCM',
      leaderStaffName: 'Trần Văn Hoàng',
      orderStatus: OrderStatus.closed,
      paymentStatus: PaymentStatus.paid,
      surveyStatus: 'Approved',
      fieldProgressStatus: 'Completed',
      hasEmergency: false,
      totalAmount: 220000000,
      paidAmount: 220000000,
    ),
  ];

  // 4. Mock Tasks for Leader & Technical Staff
  static final List<MobileTask> tasks = [
    // Leader Tasks
    MobileTask(
      id: 'TSK-LDR-001',
      taskName: 'Khảo sát hiện trường Riverside',
      orderCode: 'ORD-2026-002',
      assignedRole: UserRole.leader,
      assignedTo: 'Phan Anh Tuấn',
      location: 'Riverside Palace, Quận 4',
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      status: 'inProgress',
      priority: 'High',
      checklistItems: [
        ChecklistItem(
            label: 'Đo kích thước mặt bằng dựng rạp', isCompleted: true),
        ChecklistItem(
            label: 'Kiểm tra lối đi xe tải/xe ba gác', isCompleted: true),
        ChecklistItem(label: 'Đo độ cao dây điện cản trở', isCompleted: false),
        ChecklistItem(
            label: 'Chụp hình các góc lối vào & sân khấu', isCompleted: false),
      ],
    ),
    MobileTask(
      id: 'TSK-LDR-002',
      taskName: 'Giám sát thi công bạt che Gem Center',
      orderCode: 'ORD-2026-001',
      assignedRole: UserRole.leader,
      assignedTo: 'Phan Anh Tuấn',
      location: 'Gem Center Rooftop, Q1',
      scheduledTime: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'inProgress',
      priority: 'High',
      checklistItems: [
        ChecklistItem(
            label: 'Giám sát thợ bốc dỡ từ xe tải', isCompleted: true),
        ChecklistItem(
            label: 'Nghiệm thu khung sắt lắp đặt ban đầu', isCompleted: true),
        ChecklistItem(
            label: 'Chụp hình bạt che kéo xong gửi Manager',
            isCompleted: false),
      ],
    ),
    MobileTask(
      id: 'TSK-LDR-003',
      taskName: 'Nghiệm thu & Bàn giao ORD-003',
      orderCode: 'ORD-2026-003',
      assignedRole: UserRole.leader,
      assignedTo: 'Phan Anh Tuấn',
      location: 'Sân golf Tân Sơn Nhất',
      scheduledTime: DateTime.now().subtract(const Duration(days: 1)),
      status: 'completed',
      priority: 'Medium',
      checklistItems: [
        ChecklistItem(
            label: 'Ký biên bản bàn giao hoàn tất cho cô dâu chú rể',
            isCompleted: true),
        ChecklistItem(
            label: 'Thu hồi ảnh hóa đơn thanh toán tiền mặt phát sinh',
            isCompleted: true),
      ],
    ),

    // Technical Tasks
    MobileTask(
      id: 'TSK-TEC-001',
      taskName: 'Kiểm đếm xuất kho thiết bị rạp VIP',
      orderCode: 'ORD-2026-001',
      assignedRole: UserRole.technical,
      assignedTo: 'Nguyễn Văn Minh',
      location: 'Kho Q7, Đường Huỳnh Tấn Phát',
      scheduledTime: DateTime.now().subtract(const Duration(hours: 4)),
      status: 'completed',
      priority: 'High',
      checklistItems: [
        ChecklistItem(label: 'Đếm 80 cột thép truss', isCompleted: true),
        ChecklistItem(label: 'Soạn 100 ghế Chiavari nệm đỏ', isCompleted: true),
        ChecklistItem(label: 'Soạn 20 đèn LED par lối đi', isCompleted: true),
      ],
    ),
    MobileTask(
      id: 'TSK-TEC-002',
      taskName: 'Vận chuyển thiết bị đến Gem Center',
      orderCode: 'ORD-2026-001',
      assignedRole: UserRole.technical,
      assignedTo: 'Nguyễn Văn Minh',
      location: 'Từ Kho Q7 đến Gem Center Q1',
      scheduledTime: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'completed',
      priority: 'High',
      checklistItems: [
        ChecklistItem(label: 'Bốc hàng lên xe tải 3.5T', isCompleted: true),
        ChecklistItem(
            label: 'Lái xe/vận chuyển đến địa điểm', isCompleted: true),
        ChecklistItem(
            label: 'Hạ đồ xuống sân rooftop Gem Center', isCompleted: true),
      ],
    ),
    MobileTask(
      id: 'TSK-TEC-003',
      taskName: 'Thi công lắp ráp rạp & phông sân khấu',
      orderCode: 'ORD-2026-001',
      assignedRole: UserRole.technical,
      assignedTo: 'Nguyễn Văn Minh',
      location: 'Gem Center Rooftop, Q1',
      scheduledTime: DateTime.now().add(const Duration(hours: 2)),
      status: 'inProgress',
      priority: 'High',
      checklistItems: [
        ChecklistItem(
            label: 'Dựng khung truss sắt nâng bạt', isCompleted: true),
        ChecklistItem(label: 'Lắp bạt che mưa đỉnh rạp', isCompleted: true),
        ChecklistItem(
            label: 'Rải cỏ nhân tạo khu vực làm lễ', isCompleted: false),
        ChecklistItem(
            label: 'Xếp bàn tròn đón khách (15 bàn)', isCompleted: false),
        ChecklistItem(
            label: 'Đi dây điện chạy loa đài âm thanh', isCompleted: false),
      ],
    ),
    MobileTask(
      id: 'TSK-TEC-004',
      taskName: 'Thu hồi & dỡ rạp ORD-003',
      orderCode: 'ORD-2026-003',
      assignedRole: UserRole.technical,
      assignedTo: 'Nguyễn Văn Minh',
      location: 'Sân golf Tân Sơn Nhất',
      scheduledTime: DateTime.now().subtract(const Duration(days: 1)),
      status: 'completed',
      priority: 'Medium',
      checklistItems: [
        ChecklistItem(
            label: 'Tháo dỡ âm thanh ánh sáng sân khấu', isCompleted: true),
        ChecklistItem(label: 'Xếp gọn ghế Chiavari', isCompleted: true),
        ChecklistItem(
            label: 'Quét dọn rác thi công hiện trường', isCompleted: true),
      ],
    ),
    MobileTask(
      id: 'TSK-TEC-005',
      taskName: 'Hoàn kho & phân loại thiết bị ORD-003',
      orderCode: 'ORD-2026-003',
      assignedRole: UserRole.technical,
      assignedTo: 'Nguyễn Văn Minh',
      location: 'Kho Q7',
      scheduledTime: DateTime.now().subtract(const Duration(days: 1)),
      status: 'completed',
      priority: 'Medium',
      checklistItems: [
        ChecklistItem(
            label: 'Kiểm đếm ghế Chiavari (Gãy 2 chiếc)', isCompleted: true),
        ChecklistItem(
            label: 'Cất loa JBL về khu vực lưu trữ', isCompleted: true),
      ],
    ),
  ];

  // 5. Mock Survey Reports Pending Approval
  static final List<SurveyReport> surveyReports = [
    SurveyReport(
      id: 'SRV-001',
      orderCode: 'ORD-2026-002',
      customerName: 'Phạm Minh Tuấn & Trần Thuỳ Chi',
      location: 'Riverside Palace, Quận 4',
      leaderStaffName: 'Phan Anh Tuấn',
      surveyDate: DateTime.now().subtract(const Duration(hours: 6)),
      areaSize: 84.0,
      entranceWidth: 2.2,
      installationPosition:
          'Sân xi măng trước cửa nhà riêng. Nhỏ hẹp, mặt bằng phẳng.',
      transportationCondition:
          'Sử dụng xe đẩy tay vận chuyển thủ công từ xe tải cách 50m.',
      constructionRisk:
          'Vướng đường dây cáp quang viễn thông bắc ngang qua sân ở độ cao 3m.',
      notes:
          'Cần mang theo sào nâng đỡ dây cáp khi dựng mái bạt cưới. Kiến nghị dùng loại rạp mini 6m x 12m chiều cao đỉnh dưới 2.8m.',
      photoUrls: const ['survey_gate_01', 'survey_yard_02'],
      approvalStatus: 'Pending',
    ),
  ];

  // 6. Mock Change Requests Pending Approval
  static final List<ChangeRequest> changeRequests = [
    ChangeRequest(
      id: 'CR-001',
      orderCode: 'ORD-2026-001',
      customerName: 'Nguyễn Hoàng Nam & Lê Thị Mai',
      requestType: 'Add',
      itemName: 'Đèn LED âm trần 50W trang trí thêm',
      quantity: 20,
      reason:
          'Khách hàng muốn thắp sáng thêm khu vực lối đi ngoài trời lúc tối muộn khi đón khách.',
      costImpact: 2000000.0,
      inventoryAvailability: 'Có sẵn tại Kho Q7 (còn 90 chiếc)',
      noteFromLeader:
          'Đã tập hợp sẵn tại hiện trường sự kiện, thợ lắp ráp chờ phê duyệt từ Manager.',
      evidenceUrls: const ['cr_led_item_photo'],
      approvalStatus: 'Pending',
    ),
  ];

  // 7. Mock Payment Confirmations
  static final List<PaymentConfirmation> paymentConfirmations = [
    PaymentConfirmation(
      id: 'PAY-001',
      orderCode: 'ORD-2026-002',
      customerName: 'Phạm Minh Tuấn & Trần Thuỳ Chi',
      paymentType: 'Deposit',
      requiredAmount: 30000000.0,
      paidAmount: 30000000.0,
      paymentMethod: 'Chuyển khoản nhanh (Vietcombank)',
      evidenceUrl: 'evidence_receipt_deposit',
      submittedBy: 'Phan Anh Tuấn',
      submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: 'Pending',
    ),
    PaymentConfirmation(
      id: 'PAY-002',
      orderCode: 'ORD-2026-001',
      customerName: 'Nguyễn Hoàng Nam & Lê Thị Mai',
      paymentType: 'Final Payment',
      requiredAmount: 100000000.0,
      paidAmount: 100000000.0,
      paymentMethod: 'Chuyển khoản (MBBank)',
      evidenceUrl: 'evidence_receipt_final',
      submittedBy: 'Trần Văn Hoàng',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Approved',
    ),
  ];

  // 8. Mock Evidence Gallery Items
  static final List<EvidenceItem> evidenceItems = [
    // Survey
    EvidenceItem(
      id: 'EVI-001',
      imageUrl: 'survey_gate_01',
      type: EvidenceType.survey,
      orderCode: 'ORD-2026-002',
      uploadedBy: 'Phan Anh Tuấn',
      uploadedAt: DateTime.now().subtract(const Duration(hours: 6)),
      title: 'Lối vào hẻm 360 Bến Vân Đồn',
      note: 'Hẻm nhỏ xe tải không vào được',
    ),
    EvidenceItem(
      id: 'EVI-002',
      imageUrl: 'survey_yard_02',
      type: EvidenceType.survey,
      orderCode: 'ORD-2026-002',
      uploadedBy: 'Phan Anh Tuấn',
      uploadedAt: DateTime.now().subtract(const Duration(hours: 6)),
      title: 'Sân trước nhà lắp rạp cưới',
      note: 'Nền xi măng bằng phẳng',
    ),
    // Checkout
    EvidenceItem(
      id: 'EVI-003',
      imageUrl: 'checkout_truck_01',
      type: EvidenceType.checkout,
      orderCode: 'ORD-2026-001',
      uploadedBy: 'Nguyễn Văn Minh',
      uploadedAt: DateTime(2026, 6, 24, 6, 15),
      title: 'Bốc dỡ khung sắt rạp VIP lên xe tải 3.5 tấn',
      note: 'Đã chất xếp chắc chắn',
    ),
    // Installation
    EvidenceItem(
      id: 'EVI-004',
      imageUrl: 'install_roof_01',
      type: EvidenceType.installation,
      orderCode: 'ORD-2026-001',
      uploadedBy: 'Nguyễn Văn Minh',
      uploadedAt: DateTime(2026, 6, 24, 10, 30),
      title: 'Thi công kéo bạt mái che Gem Center',
      note: 'Dựng khung truss hoàn thiện',
    ),
    // Handover
    EvidenceItem(
      id: 'EVI-005',
      imageUrl: 'handover_full_01',
      type: EvidenceType.handover,
      orderCode: 'ORD-2026-003',
      uploadedBy: 'Trần Văn Hoàng',
      uploadedAt: DateTime(2026, 6, 17, 17, 30),
      title: 'Sân khấu hoàn thiện cắm hoa tươi ngoài trời',
      note: 'Khách hàng ký nhận bàn giao',
    ),
    // Damage/Loss
    EvidenceItem(
      id: 'EVI-006',
      imageUrl: 'damage_chair_01',
      type: EvidenceType.damageLoss,
      orderCode: 'ORD-2026-003',
      uploadedBy: 'Trần Văn Hoàng',
      uploadedAt: DateTime(2026, 6, 19, 9, 30),
      title: 'Gãy chân ghế Chiavari trong lúc tháo dỡ',
      note: 'Báo cáo hỏng 2 ghế',
    ),
    // Payment
    EvidenceItem(
      id: 'EVI-007',
      imageUrl: 'evidence_receipt_deposit',
      type: EvidenceType.payment,
      orderCode: 'ORD-2026-002',
      uploadedBy: 'Khách hàng tải lên',
      uploadedAt: DateTime.now().subtract(const Duration(hours: 3)),
      title: 'Minh chứng chuyển khoản đặt cọc 30M VNĐ',
      note: 'Vietcombank giao dịch khớp',
    ),
  ];

  // 9. Mock Field Progress steps details (Expanded view for Progress screen)
  static final Map<String, List<FieldProgressStep>> fieldProgress = {
    'ORD-2026-001': [
      FieldProgressStep(
        id: 'FPS-001',
        stepName: 'Warehouse Check-out',
        status: 'completed',
        updatedBy: 'Nguyễn Văn Minh',
        updatedAt: '06:00 24/06',
        note: 'Đã xuất kho đầy đủ khung rạp VIP và 8 loa Line Array JBL.',
        evidenceCount: 1,
      ),
      FieldProgressStep(
        id: 'FPS-002',
        stepName: 'Transportation',
        status: 'completed',
        updatedBy: 'Nguyễn Văn Minh',
        updatedAt: '07:30 24/06',
        note: 'Xe tải 3.5 tấn đã cập bến Gem Center an toàn.',
        evidenceCount: 1,
      ),
      FieldProgressStep(
        id: 'FPS-003',
        stepName: 'Installation',
        status: 'inProgress',
        updatedBy: 'Nguyễn Văn Minh',
        updatedAt: '10:15 24/06',
        note:
            'Đang tiến hành lắp ráp khung truss treo đèn và rải thảm cỏ nhân tạo.',
        evidenceCount: 1,
      ),
      FieldProgressStep(
        id: 'FPS-004',
        stepName: 'Handover',
        status: 'pending',
        updatedBy: 'Phan Anh Tuấn',
        updatedAt: '--:--',
        note: 'Chờ thợ thi công xong phần ánh sáng để nghiệm thu.',
        evidenceCount: 0,
      ),
      FieldProgressStep(
        id: 'FPS-005',
        stepName: 'Collection',
        status: 'pending',
        updatedBy: 'Nguyễn Văn Minh',
        updatedAt: '--:--',
      ),
      FieldProgressStep(
        id: 'FPS-006',
        stepName: 'Warehouse Return',
        status: 'pending',
        updatedBy: 'Nguyễn Văn Minh',
        updatedAt: '--:--',
      ),
      FieldProgressStep(
        id: 'FPS-007',
        stepName: 'Completed',
        status: 'pending',
        updatedBy: 'Phan Anh Tuấn',
        updatedAt: '--:--',
      ),
    ],
    'ORD-2026-002': [
      FieldProgressStep(
        id: 'FPS-008',
        stepName: 'Warehouse Check-out',
        status: 'pending',
        updatedBy: 'Phan Anh Tuấn',
        updatedAt: 'Chờ cọc tiền',
        note: 'Cần phê duyệt đặt cọc để mở khóa xuất kho.',
      ),
      FieldProgressStep(
        id: 'FPS-009',
        stepName: 'Transportation',
        status: 'pending',
        updatedBy: 'Phan Anh Tuấn',
        updatedAt: '--:--',
      ),
      FieldProgressStep(
        id: 'FPS-010',
        stepName: 'Installation',
        status: 'pending',
        updatedBy: 'Phan Anh Tuấn',
        updatedAt: '--:--',
      ),
    ],
  };
}
