# data "google_iam_policy" "kms_key_encrypt_decrypt" {
#   binding {
#     role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

#     members = ["serviceAccount:${google_project_service_identity.instance.email}",
#     "serviceAccount:${google_service_account.ops_agent_account.email}",
#     "${var.service_account_email}"]
#   }
# }

# resource "google_kms_crypto_key_iam_policy" "crypto_key" {
#   crypto_key_id = var.encryption_key_name
#   policy_data   = data.google_iam_policy.kms_key_encrypt_decrypt.policy_data
# }
# resource "google_kms_crypto_key_iam_policy" "crypto_key_vm" {
#   crypto_key_id = var.encryption_key_name_vm
#   policy_data   = data.google_iam_policy.kms_key_encrypt_decrypt.policy_data
# }
# resource "google_project_service_identity" "instance" {
#   provider = google-beta
#   project  = var.project_id
#   service  = "sqladmin.googleapis.com"
# }


# resource "google_kms_crypto_key_iam_binding" "iam_crypto_key_sql" {
#   crypto_key_id = var.encryption_key_name
#   role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
#   members = [
#     "serviceAccount:${google_project_service_identity.instance.email}",
#   ]
# }