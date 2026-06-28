# Audit App Manager: Frontend + Backend + Database

Phạm vi kiểm tra:

- Prompt gốc: `FE_Mobile/manager_app_feature_audit_prompt.md`
- Mobile app: `FE_Mobile/bnwems-mobile-app`
- Backend API: `BE/bnwems-backend-api`
- Database schema/migration/seed: `BE/bnwems-backend-api/prisma`

Nhận định nhanh:

- App Manager hiện có khá đầy đủ UI và route cho 8 nhóm tính năng.
- Tuy nhiên các màn hình manager hiện tại chủ yếu đang đọc `MockData` thay vì gọi `ManagerMobileService`.
- Backend đã có một số endpoint nền tảng, nhưng còn thiếu endpoint review/chi tiết/tổng hợp cho mobile manager.
- Database có nhiều bảng nền, nhưng thiếu seed data và còn lệch field so với dữ liệu UI Manager đang cần.

Ước lượng mức hoàn thành thực tế của 8 tính năng Manager App hiện tại: **khoảng 20%**.

## 1. Bảng tổng hợp trạng thái 8 tính năng

| STT | Tính năng | UI có chưa | API có chưa | DB có chưa | Dữ liệu thật/mock | Trạng thái | Ghi chú ngắn |
|---|---|---|---|---|---|---|---|
| 1 | Today Task / Today Order | Có | Có một phần | Có | Mock/Hardcode | Mock/Hardcoded | UI ở `ManagerTodayScreen` đang đọc `MockData.orders`; BE có `GET /orders`, `GET /tasks`, `GET /orders/field-progress` nhưng màn hình chưa nối service thật |
| 2 | Emergency Notification | Có | Có | Có | Mock/Hardcode | Mock/Hardcoded | UI ở `NotificationsScreen` dùng `MockData.notifications`; BE có `GET /notifications`, `PUT /notifications/:id/read`; app chưa gọi thật |
| 3 | Field Task Progress Tracking | Có | Có nhưng chưa đủ | Có | Mock + BE partial | Partial | UI timeline đang dùng `MockData.fieldProgress`; BE `GET /orders/field-progress` chỉ trả feed ngắn, chưa có timeline đầy đủ theo order |
| 4 | Survey Report Approval | Có | Chỉ có API xem, thiếu API duyệt | Có | Mock + BE partial | Partial | UI review có nút duyệt/từ chối nhưng chỉ cập nhật local; BE mới có `GET/POST /tasks/:id/survey-report`, chưa có API manager review |
| 5 | Change Request Approval | Có | Có API duyệt, thiếu API chi tiết/danh sách | Có | Mock + BE partial | Partial | UI đang đọc `MockData.changeRequests`; BE có `PUT /change-requests/:id/approve` nhưng chưa có GET chi tiết/list để mobile hiển thị thật |
| 6 | Payment Confirmation | Có | Có một phần | Có nhưng lệch nghiệp vụ | Mock + BE partial | Partial | UI đang đọc `MockData.paymentConfirmations`; BE có `GET /orders/:id/payments`, `PUT /payments/:id/confirm` nhưng chưa có luồng proof-before-confirm đúng nghiệp vụ manager |
| 7 | Order Status Checking | Có | Có một phần | Có | Mock/Hardcode | Mock/Hardcoded | UI order detail/progress đang dùng mock; BE có `GET /orders/:id`, `GET /reports/verification`, `GET /orders/:id/payments` nhưng app chưa nối |
| 8 | Evidence Viewing | Có | Có một phần | Có | Mock + BE partial | Partial | UI `EvidenceGalleryScreen` dùng `MockData.evidenceItems`; BE có bảng `evidence` nhưng chưa có endpoint tổng hợp evidence theo order |

## 2. Bảng truy vết Frontend → API → Backend → Database

| Tính năng | Frontend screen/file | API service gọi | Endpoint | Backend controller/service | Database table | Ghi chú |
|---|---|---|---|---|---|---|
| Today Task / Today Order | `lib/features/manager/today/manager_today_screen.dart` - `ManagerTodayScreen` | Có khai báo trong `lib/features/manager/services/manager_mobile_service.dart`: `getOrders`, `getTasks`, `getFieldProgressFeed` | `GET /orders`, `GET /tasks`, `GET /orders/field-progress` | `order.controller.ts#getOrders`, `task.controller.ts#getTasks`, `order.controller.ts#getFieldProgress`; service: `order.service.ts`, `task.service.ts` | `orders`, `work_tasks`, `schedule_activities`, `customers` | Màn hình thực tế chưa gọi service, vẫn đọc `MockData.orders` |
| Emergency Notification | `lib/features/notifications/screens/notifications_screen.dart` - `NotificationsScreen` | Có khai báo: `getNotifications`, `markNotificationRead` | `GET /notifications`, `PUT /notifications/:id/read` | `notification.controller.ts#getNotifications`, `markAsRead`; `notification.service.ts` | `notifications` | UI đang local mark-read, chưa gọi BE; schema notification chưa có `priority` như UI mock |
| Field Task Progress Tracking | `lib/features/manager/progress/manager_progress_screen.dart`, `lib/features/field_progress/screens/field_progress_screen.dart` | Có khai báo: `getFieldProgressFeed`, `getTasks`, `getVerificationSummary` | `GET /orders/field-progress`, `GET /tasks`, `GET /reports/verification?orderId=` | `order.controller.ts#getFieldProgress`; `task.controller.ts#getTasks`; `report.controller.ts#getVerificationReport` | `orders`, `work_tasks`, `task_progress_updates`, `schedule_activities`, `handover_records`, `damage_loss_reports` | BE hiện chưa trả timeline theo từng bước; UI timeline đang lấy `MockData.fieldProgress` |
| Survey Report Approval | `lib/features/survey_review/screens/survey_review_screen.dart` - `SurveyReviewScreen` | Có khai báo: `getSurveyReport` | `GET /tasks/:id/survey-report` | `task.controller.ts#viewSurveyReport`; `task.service.ts#viewSurveyReport` | `survey_reports`, `evidence`, `work_tasks` | Chưa tìm thấy trong source hiện tại API manager duyệt survey report |
| Change Request Approval | `lib/features/change_requests/screens/change_request_approval_screen.dart` - `ChangeRequestApprovalScreen` | Có khai báo: `approveChangeRequest` | `PUT /change-requests/:id/approve` | `changerequest.controller.ts#approveChangeRequest`; `changerequest.service.ts#approveChangeRequest` | `change_requests`, `change_request_items` | Chưa tìm thấy trong source hiện tại `GET /change-requests/:id` hoặc `GET /orders/:id/change-requests` |
| Payment Confirmation | `lib/features/payments/screens/payment_confirmation_screen.dart` - `PaymentConfirmationScreen` | Có khai báo: `getPaymentsByOrder`, `confirmPayment` | `GET /orders/:id/payments`, `PUT /payments/:id/confirm` | `payment.controller.ts#getPaymentsByOrder`, `confirmPayment`; `payment.service.ts` | `payment_requests`, `payments`, `evidence`, `orders` | Màn hình thật chưa gọi service; contract FE/BE lệch nhau về ID và status |
| Order Status Checking | `lib/features/orders/screens/order_detail_screen.dart` - `OrderDetailScreen` | Có khai báo: `getOrderDetail`, `getPaymentsByOrder`, `getVerificationSummary` | `GET /orders/:id`, `GET /orders/:id/payments`, `GET /reports/verification?orderId=` | `order.controller.ts#getOrderById`; `payment.controller.ts#getPaymentsByOrder`; `report.controller.ts#getVerificationReport` | `orders`, `customers`, `payments`, `work_tasks`, `handover_records`, `damage_loss_reports` | UI đang dựng summary bằng mock local, chưa ghép dữ liệu từ BE thật |
| Evidence Viewing | `lib/features/evidence/screens/evidence_gallery_screen.dart` - `EvidenceGalleryScreen` | Có khai báo: `getEvidenceBundle` | FE tự ghép từ `GET /tasks/:id/survey-report`, `GET /orders/:id/payments`; chưa có endpoint tổng hợp | `task.controller.ts#viewSurveyReport`, `payment.controller.ts#getPaymentsByOrder`; FE tự tổng hợp ở `ManagerMobileService#getEvidenceBundle` | `evidence`, `survey_reports`, `payments`, `handover_records`, `damage_loss_reports`, `settlements`, `inventory_reports` | Chưa tìm thấy trong source hiện tại endpoint `GET /orders/:id/evidences` |

## 3. Danh sách mock/fix cứng cần thay bằng API thật

| File | Biến/Hàm/Component | Nội dung đang mock/fix cứng | Nên thay bằng API nào | Mức độ ưu tiên |
|---|---|---|---|---|
| `lib/shared/mock/mock_data.dart` | `notifications`, `orders`, `surveyReports`, `changeRequests`, `paymentConfirmations`, `evidenceItems`, `fieldProgress` | Toàn bộ dữ liệu manager hiện tại đang nằm ở đây | Nguồn thật từ `notifications`, `orders`, `tasks`, `survey_reports`, `change_requests`, `payment_requests/payments`, `evidence` | High |
| `lib/features/manager/dashboard/manager_dashboard_screen.dart` | `ManagerDashboardScreen` | Đọc `MockData.orders`, `MockData.notifications`, `MockData.surveyReports`, `MockData.changeRequests`, `MockData.paymentConfirmations` | `GET /dashboard/manager` + `GET /notifications` + API approval queue tổng hợp | High |
| `lib/features/manager/today/manager_today_screen.dart` | `_filteredOrders`, KPI cards | Lấy toàn bộ list từ `MockData.orders` | `GET /orders`, `GET /tasks`, `GET /orders/field-progress` | High |
| `lib/features/notifications/screens/notifications_screen.dart` | `_list = MockData.notifications`, `_markAsRead` | Danh sách notification và thao tác read đang local | `GET /notifications`, `PUT /notifications/:id/read` | High |
| `lib/features/manager/progress/manager_progress_screen.dart` | `orders = MockData.orders` | KPI tiến độ và danh sách theo dõi dùng order mock | `GET /orders/field-progress` | High |
| `lib/features/field_progress/screens/field_progress_screen.dart` | `_steps = MockData.fieldProgress[_orderId]` | Timeline chi tiết từng bước đang fix cứng | Cần thêm `GET /orders/:id/field-progress` | High |
| `lib/features/survey_review/screens/survey_review_screen.dart` | `_loadReport`, `_updateStatus` | Đọc `MockData.surveyReports`, duyệt bằng local state | `GET /tasks/:id/survey-report` + cần thêm `PUT /tasks/:id/survey-report/review` | High |
| `lib/features/change_requests/screens/change_request_approval_screen.dart` | `_loadRequest`, `_updateStatus` | Đọc `MockData.changeRequests`, duyệt local, cộng tiền local vào order | `GET /change-requests/:id` + `PUT /change-requests/:id/approve` | High |
| `lib/features/payments/screens/payment_confirmation_screen.dart` | `_loadPayment`, `_updateStatus`, `_buildReceiptImageCard` | Đọc `MockData.paymentConfirmations`, proof image giả, approve local | `GET /payments/:id` hoặc `GET /orders/:id/payments` + `PUT /payments/:id/confirm` | High |
| `lib/features/orders/screens/order_detail_screen.dart` | `_loadOrderData`, `_buildEvidencePreview`, `_buildActionPanel` | Customer email hardcode, evidence preview mock, action panel đổi trạng thái local | `GET /orders/:id`, `GET /orders/:id/payments`, `GET /reports/verification`, `GET /orders/:id/evidences` | High |
| `lib/features/evidence/screens/evidence_gallery_screen.dart` | `_filteredEvidence` | Toàn bộ gallery dùng `MockData.evidenceItems` | Cần `GET /orders/:id/evidences` | High |
| `src/services/report.service.ts` | `getManagerDashboard` | `alerts: [] // Mocked` | Cần truy vấn alert thật từ `notifications`, `work_tasks`, `change_requests`, `payment_requests` | Medium |
| `src/services/report.service.ts` | `getVerificationReport` | `changeRequestsProcessed: true // Mocked` | Cần tính thật từ `change_requests` | Medium |
| `src/controllers/payment.controller.ts` | `requestPayment` | `paymentUrl: 'vnpay-mock-url'` | Cần tích hợp cổng thanh toán thật hoặc bỏ field giả | Low |

## 4. API còn thiếu cần Backend bổ sung

| Tính năng | API cần có | Method | Endpoint đề xuất | Request | Response | DB liên quan |
|---|---|---|---|---|---|---|
| Survey Report Approval | Manager review survey report | `PUT` | `/tasks/:id/survey-report/review` | `{ "status": "APPROVED|NEEDS_MORE_INFO", "reviewNote": "..." }` | survey report sau review, reviewer, reviewedAt | `survey_reports`, `evidence`, `audit_logs` |
| Change Request Approval | Lấy chi tiết change request | `GET` | `/change-requests/:id` | path `id` | full detail + items + evidences + requester | `change_requests`, `change_request_items`, `evidence`, `internal_users` |
| Change Request Approval | Lấy danh sách change request theo order | `GET` | `/orders/:id/change-requests` | path `orderId` | list change request pending/approved/rejected | `change_requests`, `change_request_items` |
| Payment Confirmation | Lấy chi tiết payment cần duyệt | `GET` | `/payments/:id` hoặc `/payment-requests/:id` | path `id` | amount, type, submitter, proof images, status | `payment_requests`, `payments`, `evidence`, `internal_users` |
| Payment Confirmation | Danh sách payment request chờ duyệt | `GET` | `/orders/:id/payment-requests` | path `orderId` | list pending payment proofs | `payment_requests`, `evidence` |
| Field Task Progress Tracking | Timeline field progress theo order | `GET` | `/orders/:id/field-progress` | path `orderId` | steps: checkout, transportation, installation, handover, collection, warehouse_return, completed | `work_tasks`, `task_progress_updates`, `inventory_reports`, `handover_records`, `damage_loss_reports`, `evidence` |
| Evidence Viewing | Tổng hợp evidence theo order | `GET` | `/orders/:id/evidences` | path `orderId`, optional `type` | grouped evidence: survey, checkout, installation, handover, damage_loss, payment, warehouse_return, settlement | `evidence`, các bảng nghiệp vụ có `refType/refId` |
| Order Status Checking | Mobile order detail tổng hợp | `GET` | `/orders/:id/mobile-summary` | path `orderId` | compact order summary cho manager mobile | `orders`, `customers`, `payments`, `work_tasks`, `survey_reports`, `change_requests`, `notifications` |
| Emergency Notification | Notification chuẩn cho manager | `GET` | `/notifications?scope=manager` | query `isRead`, `page`, `limit`, `scope` | type, priority, refType, refId, targetScreen | `notifications` |

## 5. Database còn thiếu hoặc cần chỉnh

| Tính năng | Bảng hiện có | Bảng/cột còn thiếu | Lý do cần bổ sung | Gợi ý thiết kế |
|---|---|---|---|---|
| Today Task / Today Order | `orders`, `work_tasks`, `schedule_activities` | `orders.order_number` hoặc field hiển thị tương đương | FE/service đang map `orderNumber`, nhưng schema `Order` hiện không có field này; `order.service.ts` còn filter theo `orderNumber` | Thêm `order_number` unique hoặc chuẩn hóa mã đơn hiển thị |
| Emergency Notification | `notifications` | `priority`, `target_screen`, `target_ref_type`, `target_ref_id` nếu cần | UI manager đang phân loại `High/Medium`, điều hướng nhanh theo nghiệp vụ | Mở rộng bảng `notifications` hoặc chuẩn hóa từ `refType/refId` |
| Field Task Progress Tracking | `work_tasks`, `task_progress_updates` | Chưa thiếu bảng, nhưng thiếu chuẩn step-level cho manager timeline | `getFieldProgress` hiện không dùng `task_progress_updates`, không dựng được timeline nghiệp vụ | Chuẩn hóa `progress_status` theo enum bước thi công và query gom theo order |
| Survey Report Approval | `survey_reports`, `evidence` | `review_note`, `reviewed_at` | Manager cần yêu cầu bổ sung/ghi chú review, hiện bảng chỉ có `status`, `confirmedBy` | Bổ sung note + timestamp review |
| Survey Report Approval | `survey_reports` | `area_size`, `entrance_width`, `installation_position`, `transportation_condition`, `construction_risk` | UI survey review đang cần các field này, source BE hiện không có | Thêm cột riêng hoặc JSON chi tiết khảo sát |
| Change Request Approval | `change_requests`, `change_request_items` | `reason`, `note_from_leader`, `estimated_cost`, metadata evidence | UI mock đang hiển thị lý do, ảnh, ghi chú leader, tác động chi phí; schema hiện chưa lưu đủ | Bổ sung cột text/decimal; dùng `evidence` với `refType='ChangeRequest'` |
| Payment Confirmation | `payment_requests`, `payments`, `evidence` | proof trước khi confirm, `submitted_by`, `submitted_at`, `review_note` | Nghiệp vụ manager cần xem proof rồi mới confirm; hiện `evidence` chỉ được tạo lúc confirm, nên không có proof đầu vào để duyệt | Gắn evidence vào `payment_requests` và lưu submit metadata |
| Order Status Checking | `orders`, `order_status_history` | Có thể cần map trạng thái mobile riêng | FE mock đang dùng nhiều trạng thái khác chuẩn schema hiện tại | Chuẩn hóa enum status giữa FE và BE |
| Evidence Viewing | `evidence` | Không thiếu bảng, nhưng thiếu chuẩn `refType` bao phủ đủ luồng | Cần truy vấn evidence tập trung theo order cho survey, payment, handover, damage/loss, return | Chuẩn hóa `refType` + index theo `(refType, refId)` + service tổng hợp |

## 6. Kết luận cuối cùng

- Tính năng đã hoàn thành thật sự:
  - Chưa tìm thấy trong source hiện tại tính năng nào đạt mức `Done` theo tiêu chí UI + API + DB + flow xử lý chạy thật end-to-end cho Manager App.

- Tính năng chỉ mới có UI:
  - Today Task / Today Order
  - Emergency Notification
  - Order Status Checking
  - Evidence Viewing
  - Các màn hình trên đều đã có route trong `lib/core/routes/app_routes.dart` và khai báo trong `lib/app.dart`, nhưng màn hình đang dùng `MockData`.

- Tính năng đang mock/fix cứng:
  - Dashboard Manager: `lib/features/manager/dashboard/manager_dashboard_screen.dart`
  - Today: `lib/features/manager/today/manager_today_screen.dart`
  - Notifications: `lib/features/notifications/screens/notifications_screen.dart`
  - Progress overview: `lib/features/manager/progress/manager_progress_screen.dart`
  - Field progress detail: `lib/features/field_progress/screens/field_progress_screen.dart`
  - Survey review: `lib/features/survey_review/screens/survey_review_screen.dart`
  - Change request approval: `lib/features/change_requests/screens/change_request_approval_screen.dart`
  - Payment confirmation: `lib/features/payments/screens/payment_confirmation_screen.dart`
  - Order detail: `lib/features/orders/screens/order_detail_screen.dart`
  - Evidence gallery: `lib/features/evidence/screens/evidence_gallery_screen.dart`

- Tính năng có API nhưng chưa nối vào app:
  - `GET /dashboard/manager`
  - `GET /notifications`, `PUT /notifications/:id/read`
  - `GET /orders`, `GET /orders/:id`, `GET /orders/field-progress`
  - `GET /tasks`
  - `GET /tasks/:id/survey-report`
  - `PUT /change-requests/:id/approve`
  - `GET /orders/:id/payments`, `PUT /payments/:id/confirm`
  - `GET /reports/verification`
  - Các API này đã được khai báo trong `lib/features/manager/services/manager_mobile_service.dart`, nhưng chưa thấy màn hình manager gọi service này.

- Tính năng thiếu API hoặc API chưa đủ:
  - Survey review thiếu API manager duyệt survey report.
  - Change request thiếu API detail/list cho mobile manager.
  - Field progress thiếu timeline chi tiết theo order.
  - Evidence viewing thiếu endpoint tổng hợp evidence theo order.
  - Payment confirmation thiếu API/detail model cho proof chờ duyệt trước khi confirm.

- Tính năng thiếu DB hoặc thiếu seed:
  - `prisma/seed.ts` hiện trống, chưa có seed data cho manager demo/test.
  - Survey report chưa có đủ field chi tiết khảo sát theo UI.
  - Change request chưa lưu đủ reason/note/cost/evidence như UI đang hiển thị.
  - Notification chưa có priority để hỗ trợ emergency feed.
  - Payment request chưa lưu proof/submission metadata để manager duyệt thật.

- Lỗ hổng nghiệp vụ / mismatch quan trọng:
  - `order.service.ts#getOrders` đang filter theo `orderNumber`, nhưng schema `Order` không có field này.
  - `payment.service.ts#confirmPayment` yêu cầu `status=completed`, trong khi FE manager hiện đang dùng `Approved` hoặc `Needs Evidence`.
  - `approveChangeRequestSchema` chỉ nhận `APPROVED|REJECTED`, trong khi UI mock đang dùng `Approved|Rejected`.
  - `payment.service.ts#confirmPayment` đang nhận `id` là `paymentRequestId`, nhưng FE manager route/model đặt tên là `paymentId`; contract dễ lệch.
  - `report.service.ts#getManagerDashboard` trả `alerts: []`, nên dashboard manager chưa thể có emergency feed thật.
  - `report.service.ts#getVerificationReport` đang fix cứng `changeRequestsProcessed: true`.
  - `NotificationsScreen` hiện mark-read local, không ghi nhận BE; đồng thời đang điều hướng bằng `notification.orderCode` hoặc `notification.id` kiểu mock, chưa khớp model route args thật cho survey/payment/change request.

- 3 việc ưu tiên nhất cần làm tiếp để App Manager chạy đúng nghiệp vụ:
  - Nối toàn bộ màn hình manager sang `ManagerMobileService` và bỏ `MockData` ở luồng manager.
  - Bổ sung các API còn thiếu cho survey review, change request detail/list, field-progress timeline, evidence aggregate và payment proof review.
  - Chuẩn hóa contract FE-BE-DB cho `orderNumber`, payment status, change request status, survey detail fields, notification priority.

## 7. Gợi ý task cần giao tiếp cho Frontend, Backend và Database

### Frontend

- Thay `MockData` bằng `ManagerMobileService` cho toàn bộ màn hình manager.
- Chuẩn hóa navigation args:
  - Survey review cần `taskId` + `orderId`
  - Change request cần `changeRequestId`
  - Payment confirmation cần `paymentId/paymentRequestId` thống nhất
- Tách rõ 2 loại màn hình:
  - màn hình tổng hợp list
  - màn hình detail/action submit thật
- Chuẩn hóa enum FE theo BE:
  - payment status
  - change request status
  - survey review status
  - order status

### Backend

- Bổ sung:
  - `PUT /tasks/:id/survey-report/review`
  - `GET /change-requests/:id`
  - `GET /orders/:id/change-requests`
  - `GET /orders/:id/field-progress`
  - `GET /orders/:id/evidences`
  - `GET /payments/:id` hoặc `GET /orders/:id/payment-requests`
  - `GET /orders/:id/mobile-summary`
- Sửa contract hiện có:
  - `getOrders` không dùng `orderNumber` nếu schema chưa có
  - `confirmPayment` thống nhất status với FE
  - `approveChangeRequest` thống nhất enum status
- Trả đủ response field cho mobile:
  - notification priority / ref info
  - survey detail fields
  - payment evidence/proof
  - field-progress steps

### Database

- Bổ sung seed data thật cho:
  - order đang thi công
  - notification khẩn
  - survey report chờ duyệt
  - change request chờ duyệt
  - payment request có proof chờ confirm
  - evidence cho survey/payment/handover/damage-loss/return
- Cân nhắc chỉnh schema:
  - `orders.order_number`
  - `notifications.priority`
  - survey detail columns
  - survey review note/time
  - change request reason/cost/note
  - payment request proof metadata

