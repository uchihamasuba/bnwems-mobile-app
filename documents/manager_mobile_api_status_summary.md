# Manager Mobile API Status Summary

Phuc vu bao cao nhanh cho team Frontend / Backend / PM.

Nguon doi chieu:

- FE Mobile Manager: `FE_Mobile/bnwems-mobile-app/lib/features/...`
- Manager service: `lib/features/manager/services/manager_mobile_service.dart`
- Backend API task list: `FE_Mobile/bnwems-mobile-app/documents/backend_api_task_list_for_manager_mobile.md`

## 1. API da duoc FE Manager goi that

| API | Man hinh dang dung |
|---|---|
| `GET /dashboard/manager` | `ManagerDashboardScreen` |
| `GET /notifications` | `ManagerDashboardScreen`, `NotificationsScreen`, `ManagerApprovalsScreen` |
| `PUT /notifications/:id/read` | `NotificationsScreen` |
| `GET /orders` | `ManagerDashboardScreen`, `ManagerTodayScreen` |
| `GET /orders/:id` | `OrderDetailScreen`, `FieldProgressScreen` |
| `GET /orders/field-progress` | `ManagerDashboardScreen`, `ManagerTodayScreen`, `ManagerProgressScreen` |
| `GET /tasks` | `ManagerTodayScreen`, `FieldProgressScreen`, `SurveyReviewScreen`, `EvidenceGalleryScreen`, `OrderDetailScreen` |
| `GET /tasks/:id/survey-report` | `SurveyReviewScreen`, `EvidenceGalleryScreen`, `OrderDetailScreen` |
| `GET /orders/:id/payments` | `PaymentConfirmationScreen`, `EvidenceGalleryScreen`, `OrderDetailScreen` |
| `GET /reports/verification?orderId=` | `FieldProgressScreen`, `OrderDetailScreen` |
| `PUT /change-requests/:id/approve` | `ChangeRequestApprovalScreen` |

## 2. Man hinh / chuc nang da Done

Tieu chi `Done`:

- Da bo mock cho luong chinh
- Da goi API that tu BE
- Man hinh mo len va doc du lieu that duoc

| Man hinh | Chuc nang da xong |
|---|---|
| `ManagerDashboardScreen` | Doc dashboard summary, don hom nay, notifications |
| `ManagerTodayScreen` | Doc danh sach don trong ngay, task dang chay, field-progress feed |
| `NotificationsScreen` | Doc notifications that va mark-as-read |
| `ManagerProgressScreen` | Doc field-progress feed that |
| `FieldProgressScreen` | Doc order + tasks theo order, hien timeline task that |
| `SurveyReviewScreen` | Doc survey report that o che do read-only |
| `PaymentConfirmationScreen` | Doc danh sach payment that theo order o che do read-only |
| `OrderDetailScreen` | Doc order detail, customer, payment summary, survey summary, verification summary |
| `ManagerApprovalsScreen` | Doc danh sach approval can xu ly tu notification feed that |

## 3. Man hinh / chuc nang Partial

Tieu chi `Partial`:

- Da co API that
- Da noi FE
- Nhung chua hoan thanh full nghiep vu manager end-to-end

| Man hinh | Phan da co | Phan chua xong |
|---|---|---|
| `ChangeRequestApprovalScreen` | Goi duoc `PUT /change-requests/:id/approve` | Chua co detail/list change request that |
| `EvidenceGalleryScreen` | Doc duoc survey evidence + payment evidence | Chua co evidence aggregate theo order |
| `OrderDetailScreen` | Hien duoc thong tin tong hop tu nhieu API that | Van la du lieu ghep, chua co mobile-summary API |
| `ManagerApprovalsScreen` | Loc duoc survey/change/payment tu notifications | Chua co approval queue nghiep vu rieng |
| `FieldProgressScreen` | Doc duoc task timeline that | Chua co workflow timeline chuan theo order |

## 4. Man hinh / chuc nang Blocked

Tieu chi `Blocked`:

- FE khong the lam dung nghiep vu vi BE chua co API can thiet
- Hoac contract hien tai chua an toan de dung

| Man hinh / Chuc nang | Ly do blocked |
|---|---|
| Duyet survey report that | Chua co `PUT /tasks/:id/survey-report/review` |
| Xem chi tiet change request that | Chua co `GET /change-requests/:id` hoac `GET /orders/:id/change-requests` |
| Xac nhan payment that tu manager | Contract `PUT /payments/:id/confirm` hien tai chua on dinh voi FE manager |
| Mo payment detail bang `paymentId` | Chua co `GET /payments/:id` hoac `GET /payment-requests/:id` |
| Evidence gallery full theo order | Chua co `GET /orders/:id/evidences` |
| Approval queue manager day du | Chua co `GET /manager/approvals` hoac endpoint list survey/payment/change requests cho manager |

## 5. Ket luan nhanh

- FE Manager da noi that duoc phan lon cac man doc du lieu.
- Nhom man da on nhat hien tai la:
  - Dashboard
  - Today
  - Notifications
  - Progress feed
  - Order detail
- Nhom nghiep vu chua chay full end-to-end la:
  - Duyet survey
  - Duyet phat sinh voi detail that
  - Xac nhan payment that
  - Evidence tong hop theo order

## 6. Danh sach uu tien tiep theo

| Uu tien | Viec can lam |
|---|---|
| High | Them API review survey report |
| High | Them API detail/list change request |
| High | Chuan hoa payment confirm + payment detail API |
| High | Them evidence aggregate theo order |
| Medium | Them manager approvals queue API |
| Medium | Them mobile order summary API |
