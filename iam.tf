resource "aws_iam_user" "taka_assume_role_bucket_executor" {
  name = "taka_assume_role_bucket_executor"
}

resource "aws_s3_bucket" "taka_assume_role_test" {
  bucket = "taka-assume-roletest"
}

data "aws_iam_policy_document" "taka_assume_role_test_bucket_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.taka_assume_role_test.arn,
      "${aws_s3_bucket.taka_assume_role_test.arn}/*"
    ]
  }
}


resource "aws_iam_policy" "taka_assume_role_bucket_access_policy" {
  name   = "taka_assume_role_bucket_access_policy"
  policy = data.aws_iam_policy_document.taka_assume_role_test_bucket_access.json
}


resource "aws_iam_role" "taka_assume_role_bucket_maintainer_role" {
  name = "taka_assume_role_bucket_maintainer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      "Principal": {
        "AWS": aws_iam_user.taka_assume_role_bucket_executor.arn
      },
      Action   = "sts:AssumeRole"
      Effect   = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "taka_assume_role_bucket_access_polcy_and_role_attachment" {
  role       = aws_iam_role.taka_assume_role_bucket_maintainer_role.name
  policy_arn = aws_iam_policy.taka_assume_role_bucket_access_policy.arn
}
