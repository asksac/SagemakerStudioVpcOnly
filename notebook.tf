## SageMaker Notebook 

/*
resource "aws_sagemaker_notebook_instance" "ni" {
  name                      = "${var.app_shortcode}_notebook_01"
  role_arn                  = aws_iam_role.ss_exec_role.arn
  instance_type             = "ml.t3.medium"

  subnet_id                 = var.subnet_ids[0]
  security_groups           = [ aws_security_group.sagemaker_sg.id ]
}
*/