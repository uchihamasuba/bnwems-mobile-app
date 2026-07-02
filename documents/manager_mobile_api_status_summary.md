# Manager Mobile API Status Summary

Phục vụ báo cáo nhanh cho team Frontend / Backend / PM.

Nguồn đối chiếu:

- FE Mobile Manager: `FE_Mobile/bnwems-mobile-app/lib/features/...`
- Manager service: `lib/features/manager/services/manager_mobile_service.dart`
- Backend API task list: `FE_Mobile/bnwems-mobile-app/documents/backend_api_task_list_for_manager_mobile.md`

## 1. API đã được FE Manager gọi thật

| API                                | Màn hình đang dùng                                                                    |
|------------------------------------|---------------------------------------------------------------------------------------|
| `GET /dashboard/manager`           | `ManagerDashboardScreen`                                                              |
| `GET /notifications`               | `ManagerDashboardScreen`, `NotificationsScreen`, `ManagerApprovalsScreen`             |
| `PUT /notifications/:id/read`      | `NotificationsScreen`                                                                 |
| `GET /orders`                      | `ManagerDashboardScreen`, `ManagerTodayScreen`                                        |
| `GET /orders/:id`                  | `OrderDetailScreen`, `FieldProgressScreen`                                            |
| `GET /orders/field-progress`       | `ManagerDashboardScreen`, `ManagerTodayScreen`, `ManagerProgressScreen`               |
| `GET /tasks`                       | `ManagerTodayScreen`, `FieldProgressScreen`, `SurveyReviewScreen`, `EvidenceGalleryScreen`, `OrderDetailScreen` |
| `GET /tasks/:id/survey-report`     | `SurveyReviewScreen`, `EvidenceGalleryScreen`, `OrderDetailScreen`                    |
| `GET /orders/:id/payments`         | `PaymentConfirmationScreen`, `EvidenceGalleryScreen`, `OrderDetailScreen`             |
| `GET /reports/verification?orderId=` | `FieldProgressScreen`, `OrderDetailScreen`                                          |
| `PUT /change-requests/:id/approve` | `ChangeRequestApprovalScreen`                                                         |

## 2. Màn hình / chức năng đã Done

Tiêu chí `Done`:

- Đã bỏ mock cho luồng chính
- Đã gọi API thật từ BE
- Màn hình mở lên và đọc dữ liệu thật được

| Màn hình                   | Chức năng đã xong                                                         |
|---------------------------|---------------------------------------------------------------------------|
| `ManagerDashboardScreen`  | Đọc dashboard summary, đơn hôm nay, notifications                         |
| `ManagerTodayScreen`      | Đọc danh sách đơn trong ngày, task đang chạy, field-progress feed         |
| `NotificationsScreen`     | Đọc notifications thật và mark-as-read                                    |
| `ManagerProgressScreen`   | Đọc field-progress feed thật                                              |
| `FieldProgressScreen`     | Đọc order + tasks theo order, hiển thị timeline task thật                 |
| `SurveyReviewScreen`      | Đọc survey report thật ở chế độ read-only                                 |
| `PaymentConfirmationScreen` | Đọc danh sách payment thật theo order ở chế độ read-only               |
| `OrderDetailScreen`       | Đọc order detail, customer, payment summary, survey summary, verification summary |
| `ManagerApprovalsScreen`  | Đọc danh sách approval cần xử lý từ notification feed thật                |

## 3. Màn hình / chức năng Partial

Tiêu chí `Partial`:

- Đã có API thật
- Đã nối FE
- Nhưng chưa hoàn thành full nghiệp vụ manager end-to-end

| Màn hình                      | Phần đã có                                      | Phần chưa xong                                |
|------------------------------|-------------------------------------------------|-----------------------------------------------|
| `ChangeRequestApprovalScreen` | Gọi được `PUT /change-requests/:id/approve`    | Chưa có detail/list change request thật       |
| `EvidenceGalleryScreen`      | Đọc được survey evidence + payment evidence     | Chưa có evidence aggregate theo order         |
| `OrderDetailScreen`          | Hiển thị được thông tin tổng hợp từ nhiều API thật | Vẫn là dữ liệu ghép, chưa có mobile-summary API |
| `ManagerApprovalsScreen`     | Lọc được survey/change/payment từ notifications | Chưa có approval queue nghiệp vụ riêng        |
| `FieldProgressScreen`        | Đọc được task timeline thật                     | Chưa có workflow timeline chuẩn theo order    |

## 4. Màn hình / chức năng Blocked

Tiêu chí `Blocked`:

- FE không thể làm đúng nghiệp vụ vì BE chưa có API cần thiết
- Hoặc contract hiện tại chưa an toàn để dùng

| Màn hình / Chức năng              | Lý do blocked                                                                      |
|-----------------------------------|------------------------------------------------------------------------------------|
| Duyệt survey report thật          | Chưa có `PUT /tasks/:id/survey-report/review`                                      |
| Xem chi tiết change request thật  | Chưa có `GET /change-requests/:id` hoặc `GET /orders/:id/change-requests`         |
| Xác nhận payment thật từ manager  | Contract `PUT /payments/:id/confirm` hiện tại chưa ổn định với FE manager         |
| Mở payment detail bằng `paymentId` | Chưa có `GET /payments/:id` hoặc `GET /payment-requests/:id`                     |
| Evidence gallery full theo order  | Chưa có `GET /orders/:id/evidences`                                               |
| Approval queue manager đầy đủ     | Chưa có `GET /manager/approvals` hoặc endpoint list survey/payment/change requests cho manager |

## 5. Kết luận nhanh

- FE Manager đã nối thật được phần lớn các màn đọc dữ liệu.
- Nhóm màn đã ổn nhất hiện tại là:
  - Dashboard
  - Today
  - Notifications
  - Progress feed
  - Order detail
- Nhóm nghiệp vụ chưa chạy full end-to-end là:
  - Duyệt survey
  - Duyệt phát sinh với detail thật
  - Xác nhận payment thật
  - Evidence tổng hợp theo order

Ghi chú thêm cho 4 phần trên:

- Duyệt survey: chưa có API `PUT /tasks/:id/survey-report/review`.
- Duyệt phát sinh với detail thật: chưa có API `GET /change-requests/:id` hoặc `GET /orders/:id/change-requests`.
- Xác nhận payment thật: API `PUT /payments/:id/confirm` hiện tại chưa ổn định với FE manager; đồng thời còn thiếu API detail như `GET /payments/:id` nếu muốn mở trực tiếp theo `paymentId`.
- Evidence tổng hợp theo order: chưa có API `GET /orders/:id/evidences`.

## 6. Danh sách ưu tiên tiếp theo

| Ưu tiên | Việc cần làm                               |
|---------|--------------------------------------------|
| High    | Thêm API review survey report              |
| High    | Thêm API detail/list change request        |
| High    | Chuẩn hóa payment confirm + payment detail API |
| High    | Thêm evidence aggregate theo order         |
| Medium  | Thêm manager approvals queue API           |
| Medium  | Thêm mobile order summary API              |

## 7. Bảng đối chiếu tính năng manager mobile

| STT | Tính năng                    | Trạng thái       | Lý do                                                                  | API còn thiếu                                                              |
|-----|------------------------------|------------------|------------------------------------------------------------------------|----------------------------------------------------------------------------|
| 1   | Today Task / Today Order     | Gần như Done     | Đã xem được đơn trong ngày, task đang chạy, feed tiến độ thật.        | Không có API thiếu mang tính chặn luồng chính.                            |
| 2   | Emergency Notification       | Done             | Đã đọc thông báo thật, lọc nhóm, mark-as-read, điều hướng liên màn.   | Không có API thiếu cho luồng đọc và xử lý cơ bản.                         |
| 3   | Field Task Progress Tracking | Partial          | Đã có feed tiến độ và timeline task theo order, chưa đủ workflow full.| Chưa có API timeline chuẩn theo từng bước nghiệp vụ của order.            |
| 4   | Survey Report Approval       | Partial/Blocked  | Đã xem báo cáo, ảnh, ghi chú; chưa duyệt/yêu cầu bổ sung thật.        | `PUT /tasks/:id/survey-report/review`                                     |
| 5   | Change Request Approval      | Partial          | Đã approve/reject được, nhưng chưa có list/detail change request thật.| `GET /change-requests/:id`, `GET /orders/:id/change-requests`             |
| 6   | Payment Confirmation         | Partial/Blocked  | Đã xem payment theo order, chưa xác nhận payment thật ổn định.        | `PUT /payments/:id/confirm`, `GET /payments/:id` hoặc endpoint detail tương đương |
| 7   | Order Status Checking        | Gần như Done     | Đã xem status đơn, payment summary, verification, timeline tổng hợp.  | Chưa bắt buộc; nếu cần gọn hơn thì thêm mobile summary API.               |
| 8   | Evidence Viewing             | Partial          | Đã xem survey evidence và payment evidence, chưa đủ loại theo order.  | `GET /orders/:id/evidences`                                               |

Ghi chú để đọc nhanh:

- `Done`: đã đọc dữ liệu thật và dùng được cho luồng chính.
- `Gần như Done`: đã dùng ổn cho người dùng, chỉ còn thiếu tối ưu hoặc API tổng hợp.
- `Partial`: đã nối được một phần nghiệp vụ, nhưng chưa chạy full end-to-end.
- `Partial/Blocked`: FE đã có màn hình đọc dữ liệu, nhưng phần thao tác chính bị thiếu API.
