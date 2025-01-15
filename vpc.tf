resource "aws_vpc" "yt_live" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.project}-vpc"
  }
}


resource "aws_subnet" "yk_live_public_1a" {
  vpc_id                  = aws_vpc.yt_live.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-1a"
  }
}

resource "aws_subnet" "yk_live_public_1c" {
  vpc_id                  = aws_vpc.yt_live.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-1c"
  }
}

resource "aws_internet_gateway" "yt_live" {
  vpc_id = aws_vpc.yt_live.id

  tags = {
    Name = "${var.project}-igw"
  }
}

resource "aws_route_table" "yt_live_public" {
  vpc_id = aws_vpc.yt_live.id

  tags = {
    Name = "${var.project}-public-rt"
  }
}

resource "aws_route" "yt_live_public" {
  route_table_id         = aws_route_table.yt_live_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.yt_live.id
}

resource "aws_route_table_association" "yt_live_public_1a" {
  subnet_id      = aws_subnet.yk_live_public_1a.id
  route_table_id = aws_route_table.yt_live_public.id
}

resource "aws_route_table_association" "yt_live_public_1c" {
  subnet_id      = aws_subnet.yk_live_public_1c.id
  route_table_id = aws_route_table.yt_live_public.id
}
