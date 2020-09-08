resource "aws_ecr_repository" "foo" {
  name                 = "${var.team}/${var.application}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
