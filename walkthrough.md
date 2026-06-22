# Hướng dẫn Kiểm tra & Vận hành: Mobile App 3 Vai Trò (Manager, Leader Staff, Technical Staff)

Chào bạn, hệ thống di động phục vụ cho cả 3 vai trò vận hành thực địa của dự án **Binh Nguyen Wedding & Event Management System (BNWEMS)** đã được tái cấu trúc và hoàn thiện. Toàn bộ mã nguồn đã vượt qua kiểm tra tĩnh `flutter analyze` và các kiểm thử đơn vị tự động thành công 100%.

---

## 1. Cấu trúc Thư mục đã Refactor

Cấu trúc thư mục được tổ chức theo module/feature rõ ràng và dọn dẹp các tệp tin cũ không sử dụng:

```text
lib/
├── main.dart                                    # Khởi chạy ứng dụng
├── app.dart                                     # Cấu hình MaterialApp và điều phối 29 định tuyến
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                      # Tone màu chủ đạo Indigo/Lavender, Success, Warning, Error
│   │   ├── app_sizes.dart                       # Padding, Spacing, Radius chuẩn Material 3
│   │   └── app_strings.dart                     # Nhãn chữ tĩnh chuẩn hóa
│   ├── theme/
│   │   └── app_theme.dart                       # ThemeData Material 3
│   ├── routes/
│   │   └── app_routes.dart                      # Định nghĩa 29 định tuyến phân chia rõ theo phân vai
│   └── widgets/                                 # UI Components tái sử dụng (PrimaryButton, InfoCard, status chip...)
├── shared/
│   ├── models/
│   │   ├── core_models.dart                     # Hệ thống 9 models trung tâm (AppUser, MobileNotification, MobileOrder, MobileTask, FieldProgressStep, SurveyReport, ChangeRequest, PaymentConfirmation, EvidenceItem)
│   │   ├── order_status.dart                    # Trạng thái đơn hàng
│   │   ├── payment_status.dart                  # Trạng thái thanh toán
│   │   ├── approval_status.dart                 # Trạng thái phê duyệt (Pending, Approved, Rejected, Need More Info)
│   │   ├── evidence_type.dart                   # Phân loại ảnh hiện trường
│   │   ├── task_status.dart                     # Trạng thái công việc
│   │   └── user_role.dart                       # Enum phân vai (manager, leader, technical)
│   └── mock/
│       └── mock_data.dart                       # Cơ sở dữ liệu Mock trung tâm cho 3 vai trò
└── features/
    ├── auth/
    │   └── screens/
    │       └── login_screen.dart                # Đăng nhập với 3 nút quick-select vai trò tương ứng
    ├── manager/
    │   ├── widgets/
    │   │   └── manager_app_shell.dart           # Khung Bottom Navigation cho Manager
    │   ├── dashboard/
    │   │   └── manager_dashboard_screen.dart    # Dashboard của Manager (Duyệt nhanh, Cảnh báo khẩn)
    │   └── today/
    │       └── manager_today_screen.dart        # Giám sát đơn hàng chạy trong ngày hiện tại
    ├── leader/
    │   ├── widgets/
    │   │   └── leader_app_shell.dart            # Khung Bottom Navigation cho Leader Staff
    │   ├── dashboard/
    │   │   └── leader_dashboard_screen.dart     # Dashboard hiển thị việc cần làm và cảnh báo hôm nay
    │   ├── tasks/
    │   │   ├── leader_task_list_screen.dart     # Danh sách tác vụ giám sát
    │   │   └── leader_task_detail_screen.dart   # Chi tiết công việc giám sát
    │   ├── survey/
    │   │   └── leader_survey_report_screen.dart # Form lập báo cáo khảo sát hiện trường
    │   ├── progress_update/
    │   │   └── leader_progress_update_screen.dart # Cập nhật tiến trình thi công của đội kỹ thuật
    │   ├── change_requests/
    │   │   └── leader_create_change_request_screen.dart # Gửi yêu cầu thay đổi/phát sinh thiết bị
    │   ├── handover/
    │   │   └── leader_handover_report_screen.dart # Báo cáo nghiệm thu & bàn giao lễ hội
    │   ├── damage_loss/
    │   │   └── leader_damage_loss_report_screen.dart # Báo cáo hỏng hóc/mất mát vật tư
    │   ├── payment_evidence/
    │   │   └── leader_payment_evidence_upload_screen.dart # Upload ảnh biên lai chuyển khoản từ khách hàng
    │   └── warehouse_return/
    │       └── leader_warehouse_return_report_screen.dart # Báo cáo hoàn trả thiết bị về kho Q7
    ├── technical/
    │   ├── widgets/
    │   │   └── technical_app_shell.dart         # Khung Bottom Navigation cho Technical Staff
    │   ├── dashboard/
    │   │   └── technical_dashboard_screen.dart  # Thống kê tác vụ thi công hôm nay
    │   ├── tasks/
    │   │   ├── technical_task_list_screen.dart  # Đầu việc thi công được giao
    │   │   ├── technical_task_detail_screen.dart # Chi tiết lắp ráp, thu dỡ của kỹ thuật viên
    │   │   └── technical_evidence_upload_screen.dart # Tải lên ảnh minh chứng hoàn thành
    │   ├── pick_list/
    │   │   └── technical_pick_list_screen.dart  # Kiểm đếm xuất kho vật tư trước sự kiện
    │   ├── transportation/
    │   │   └── technical_transportation_screen.dart # Ghi nhận trạng thái chuyển vận (In Transit -> Arrived)
    │   ├── installation/
    │   │   └── technical_installation_checklist_screen.dart # Checklist thi công lắp ráp phông rạp
    │   ├── collection/
    │   │   └── technical_collection_checklist_screen.dart # Checklist thu hồi thiết bị sau sự kiện
    │   └── warehouse_return/
    │       └── technical_warehouse_return_screen.dart # Kiểm đếm hoàn trả kho hàng
    ├── notifications/
    │   └── screens/
    │       └── notifications_screen.dart        # Hộp thư thông báo dùng chung, tự chuyển tiếp thông minh theo vai trò
    ├── evidence/
    │   └── screens/
    │       └── evidence_gallery_screen.dart     # Thư viện ảnh minh chứng, lọc linh hoạt theo giai đoạn
    ├── orders/
    │   └── screens/
    │       └── order_detail_screen.dart         # Chi tiết đơn hàng, tự ẩn/hiện bảng điều khiển duyệt của Manager
    ├── survey_review/
    │   └── screens/
    │       └── survey_review_screen.dart        # Màn hình duyệt khảo sát (Manager)
    ├── change_requests/
    │   └── screens/
    │       └── change_request_approval_screen.dart # Màn hình duyệt đổi/thêm thiết bị (Manager)
    └── payments/
        └── screens/
            └── payment_confirmation_screen.dart # Màn hình duyệt biên lai giao dịch (Manager)
```

---

## 2. Kết quả Kiểm thử & Phân tích tĩnh

Chúng ta đã tiến hành xác thực tính đúng đắn trực tiếp trên hệ thống:

### A. Kiểm tra cú pháp tĩnh (`flutter analyze`)
- **Kết quả**: **Hoàn toàn sạch**. Không còn bất kỳ lỗi biên dịch (Compile Error), import sai hay thiếu kiểu dữ liệu nào.

### B. Kiểm thử đơn vị tự động (`flutter test`)
- **Kết quả**: **Vượt qua thành công 100%**. Widget test trang Login đã kiểm chứng đúng nhãn nút bấm vận hành mới.

---

## 3. Hướng dẫn Chạy & Kiểm tra Demo nhanh

1. Chạy ứng dụng trên máy ảo/thiết bị thật bằng lệnh `flutter run`.
2. Màn hình đăng nhập sẽ hiển thị 3 tài khoản Đăng nhập nhanh cho 3 vai trò:
   - **Manager** (`manager@test.com`): Sau khi đăng nhập, hệ thống hiển thị Dashboard của Manager. Cho phép bấm duyệt Báo cáo khảo sát, Change Request phát sinh chi phí và Biên lai cọc tiền.
   - **Leader Staff** (`leader@test.com`): Hiển thị Dashboard quản lý đội kỹ thuật. Hỗ trợ tạo các báo cáo khảo sát, yêu cầu đổi thiết bị, upload ảnh thanh toán và báo cáo mất mát vật tư.
   - **Technical Staff** (`technical@test.com`): Giao diện checklist tinh gọn. Cho phép soạn đồ xuất kho, vận chuyển thiết bị, checklist thi công phông bạt và dỡ rạp.
3. Khi bấm vào các thông báo hoặc chi tiết đơn hàng, hệ thống sẽ tự động hiển thị hoặc ẩn các nút phê duyệt dựa trên vai trò của màn hình hiện tại cực kỳ thông minh.
