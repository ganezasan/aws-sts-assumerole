resource "aws_iam_user" "assume_role_bucket_executor" {
  name = "${var.name}_assume_role_bucket_executor"
}

resource "aws_s3_bucket" "assume_role_test" {
  bucket = "${var.name}-assume-role-test"
}

data "aws_iam_policy_document" "assume_role_test_bucket_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.assume_role_test.arn,
      "${aws_s3_bucket.assume_role_test.arn}/*"
    ]
  }
}


resource "aws_iam_policy" "assume_role_bucket_access_policy" {
  name   = "${var.name}_assume_role_bucket_access_policy"
  policy = data.aws_iam_policy_document.assume_role_test_bucket_access.json
}


resource "aws_iam_role" "assume_role_bucket_maintainer_role" {
  name = "${var.name}_assume_role_bucket_maintainer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      "Principal": {
        "AWS": aws_iam_user.assume_role_bucket_executor.arn
      },
      Action   = "sts:AssumeRole"
      Effect   = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "assume_role_bucket_access_polcy_and_role_attachment" {
  role       = aws_iam_role.assume_role_bucket_maintainer_role.name
  policy_arn = aws_iam_policy.assume_role_bucket_access_policy.arn
}
