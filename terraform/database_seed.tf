# ============================================================
# AUTOMATIC MONGODB SEEDING (Runs on every Terraform Apply)
# ============================================================
resource "null_resource" "mongodb_seed" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      # 1. Start port-forward to MongoDB on EKS in background
      kubectl port-forward -n cloudkart svc/mongodb-service 27017:27017 &
      PF_PID=$!

      # 2. Wait until the local port 27017 opens (using python socket test)
      for i in {1..15}; do
        if python3 -c "import socket; s = socket.socket(); s.settimeout(2); s.connect(('127.0.0.1', 27017))" 2>/dev/null; then
          echo ">>> MongoDB tunnel established."
          break
        fi
        echo "Waiting for MongoDB port-forward..."
        sleep 2
      done

      # 3. Execute the migration script
      echo ">>> Executing data migration..."
      MONGODB_URI=mongodb://127.0.0.1:27017/cloudkart npm run migrate

      # 4. Clean up background process
      echo ">>> Cleaning up port-forward tunnel."
      kill $PF_PID || true
    EOT
    working_dir = "${path.module}/.."
  }

  depends_on = [module.eks]
}
