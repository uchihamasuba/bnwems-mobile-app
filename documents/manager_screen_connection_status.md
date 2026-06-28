# Manager Mobile Screen Connection Status

Nguon doi chieu:

- FE mobile: `FE_Mobile/bnwems-mobile-app/lib/features/...`
- Service: `lib/features/manager/services/manager_mobile_service.dart`
- Seed DB: `BE/bnwems-backend-api/prisma/seed.ts`

## 1. Man hinh da noi duoc voi API + seed hien tai

| Man hinh FE | File | API dang goi that | Seed test duoc | Trang thai |
|---|---|---|---|---|
| Manager Dashboard | `lib/features/manager/dashboard/manager_dashboard_screen.dart` | `GET /dashboard/manager`, `GET /notifications`, `GET /orders`, `GET /orders/field-progress` | `manager`, `orderInProgress`, `orderVerificationReady` | Connected |
| Manager Today | `lib/features/manager/today/manager_today_screen.dart` | `GET /orders`, `GET /tasks?status=in_progress`, `GET /orders/field-progress` | `orderInProgress`, `orderVerificationReady` | Connected |
| Notifications | `lib/features/notifications/screens/notifications_screen.dart` | `GET /notifications`, `PUT /notifications/:id/read` | 5 manager notifications | Connected |
| Manager Progress Overview | `lib/features/manager/progress/manager_progress_screen.dart` | `GET /orders/field-progress` | `orderInProgress`, `orderVerificationReady` | Connected |
| Manager Approvals | `lib/features/manager/approvals/manager_approvals_screen.dart` | `GET /dashboard/manager`, `GET /notifications` | survey/change/payment notifications + pending count | Partial |
| Order Detail | `lib/features/orders/screens/order_detail_screen.dart` | `GET /orders/:id`, `GET /orders/:id/payments`, `GET /tasks`, `GET /tasks/:id/survey-report`, `GET /reports/verification` | `orderInProgress`, `orderVerificationReady` | Partial |
| Survey Review | `lib/features/survey_review/screens/survey_review_screen.dart` | `GET /tasks/:id/survey-report`, fallback `GET /tasks?orderId=` | `surveyTask` cua `orderInProgress` | Partial |
| Change Request Approval | `lib/features/change_requests/screens/change_request_approval_screen.dart` | `PUT /change-requests/:id/approve` | `changeRequest` cua `orderInProgress` | Partial |
| Payment Confirmation | `lib/features/payments/screens/payment_confirmation_screen.dart` | `GET /orders/:id/payments`, `PUT /payments/:id/confirm` | `orderInProgress` co `reviewPayment`, `orderVerificationReady` co `confirmedPayment` | Partial |
| Evidence Gallery | `lib/features/evidence/screens/evidence_gallery_screen.dart` | FE ghep `GET /tasks/:id/survey-report` + `GET /orders/:id/payments` | `orderInProgress`, `orderVerificationReady` | Partial |

## 2. Man hinh dang bi block hoac chi chay trong dieu kien han che

| Man hinh FE | Dieu kien dang block | API thieu/lech |
|---|---|---|
| Field Progress Detail | `lib/features/field_progress/screens/field_progress_screen.dart` goi `GET /reports/verification` bat buoc. Order dang thi cong se loi neu task chua `done`. Man nay chi test on voi `orderVerificationReady`. | Thieu `GET /orders/:id/field-progress`; FE nen khong bat verification summary bat buoc cho moi order |
| Survey Review action | Hai nut `Phe duyet` / `Yeu cau bo sung` chi show snackbar | Thieu `PUT /tasks/:id/survey-report/review` |
| Change Request Approval detail | Man hinh khong tai duoc detail item/reason/evidence that | Thieu `GET /change-requests/:id` hoac `GET /orders/:id/change-requests` |
| Change Request Approval tu Order Detail | `order_detail_screen.dart` dang mo route voi `changeRequestId=''`, nen khong submit that duoc | Thieu API list/detail change request theo order de FE lay ra ID that |
| Payment Confirmation mo bang `paymentId` | Neu route chi co `paymentId` ma khong co `orderId`, FE khong tai duoc detail | Thieu `GET /payments/:id` hoac `GET /payment-requests/:id` |
| Payment Confirmation action submit | FE goi `PUT /payments/:id/confirm`, nhung contract BE hien tai van co rui ro lech giua `paymentId` va `paymentRequestId`, va luong proof review chua day du | API co nhung contract chua on dinh |
| Evidence Gallery mo doc lap | Neu khong truyen `orderId`, man hinh chi hien gap card | Thieu `GET /orders/:id/evidences` |
| Evidence Gallery full scope | Hien chi ghep duoc survey + payment evidence | Thieu endpoint tong hop handover, damage/loss, warehouse return, settlement evidence |
| Manager Approvals queue | Chi co count + notification, chua co queue detail that | Thieu list survey approvals, payment requests, change request detail/list |
| Dashboard alert zone | `alerts` trong `GET /dashboard/manager` van rong | Backend chua bo sung alert feed nghiep vu |

## 3. Route/test data nen dung

| Muc tieu test | Du lieu seed nen mo |
|---|---|
| Dashboard / Today / Notifications | Login `manager / Password123!` |
| Survey review that | Notification `Survey` hoac `surveyTask` da seed |
| Change request action that | Notification `Change Request` cua `changeRequest` |
| Payment review co proof | Notification `Payment` hoac mo Payment screen voi `orderId = orderInProgress` |
| Order detail co verification | `orderVerificationReady` |
| Order detail co survey/change/payment pending | `orderInProgress` |
| Field progress detail khong loi verification | `orderVerificationReady` |

## 4. Ket luan nhanh

- Da bo `MockData` o cac man hinh Manager chinh va da noi vao `ManagerMobileService`.
- Co 4 man hinh da dung du lieu that kha on: Dashboard, Today, Notifications, Progress Overview.
- Cac man hinh con lai da doc du lieu that mot phan, nhung van bi gioi han boi API backend thieu detail/review/aggregate.
- Man bi block ro nhat hien tai la `FieldProgressScreen`, `SurveyReviewScreen`, `ChangeRequestApprovalScreen`, `PaymentConfirmationScreen`, `EvidenceGalleryScreen` o cac luong can API detail hoac action review day du.
