variable "UPSTREAM_REGISTRY" {
  default = "ghcr.io"
}
variable "UPSTREAM_SLUG" {
  default = "andrewrothstein/docker-ansible"
}
variable "UPSTREAM_TAG" {}

variable "TARGET_REGISTRY" {
  default = "ghcr.io"
}
variable "TARGET_SLUG" {}
variable "TARGET_TAG" {}
variable "SHA" {}

target "default" {
  context = BAKE_CMD_CONTEXT
  dockerfile-inline = <<-EOF
  FROM ${UPSTREAM_REGISTRY}/${UPSTREAM_SLUG}:${UPSTREAM_TAG}
  ENV TEST_PLAYBOOK_DIR=/test-playbook${SHA}
  RUN mkdir -p $TEST_PLAYBOOK_DIR
  ADD . $TEST_PLAYBOOK_DIR
  WORKDIR $TEST_PLAYBOOK_DIR
  RUN if [ -f requirements.yml ]; then ansible-galaxy install -r requirements.yml; fi
  RUN if [ -f meta/requirements.yml ]; then ansible-galaxy install -r meta/requirements.yml; fi
  RUN if [ -f test-requirements.yml ]; then ansible-galaxy install -r test-requirements.yml; fi
  RUN if [ -f test-inventory.ini ]; then ansible-playbook -i test-inventory.ini test.yml; else ansible-playbook test.yml; fi
  EOF
  labels = {
    maintainer = "Andrew Rothstein andrew.rothstein@gmail.com"
  }
  platforms = [
    "linux/amd64"
  ]
  tags = [
    "${TARGET_REGISTRY}/${TARGET_SLUG}:${TARGET_TAG}"
  ]
}
