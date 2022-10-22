resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 120"
  }

  depends_on = [
    local_file.inventory
  ]
}

#resource "null_resource" "cluster" {
#  provisioner "local-exec" {
#    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/1_play.yml"
#  }
#
#  depends_on = [
#    null_resource.wait
#  ]
#}
