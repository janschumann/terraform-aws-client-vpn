terraform {
  required_version = ">= 0.12.26"
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "a" {
  cidr_block = "10.100.0.0/16"
}

resource "aws_subnet" "aa" {
  vpc_id            = aws_vpc.a.id
  cidr_block        = "10.100.100.0/24"
  availability_zone = "eu-central-1a"
}

resource "aws_subnet" "ab" {
  vpc_id            = aws_vpc.a.id
  cidr_block        = "10.100.101.0/24"
  availability_zone = "eu-central-1b"
}

resource "aws_subnet" "ac" {
  vpc_id            = aws_vpc.a.id
  cidr_block        = "10.100.102.0/24"
  availability_zone = "eu-central-1c"
}

resource "aws_subnet" "ac2" {
  vpc_id            = aws_vpc.a.id
  cidr_block        = "10.100.103.0/24"
  availability_zone = "eu-central-1c"
}

resource "aws_vpc" "b" {
  cidr_block = "10.101.0.0/16"
}

resource "aws_subnet" "ba" {
  vpc_id            = aws_vpc.b.id
  cidr_block        = "10.101.100.0/24"
  availability_zone = "eu-central-1a"
}

resource "aws_subnet" "bb" {
  vpc_id            = aws_vpc.b.id
  cidr_block        = "10.101.101.0/24"
  availability_zone = "eu-central-1b"
}

resource "aws_subnet" "bc" {
  vpc_id            = aws_vpc.b.id
  cidr_block        = "10.101.102.0/24"
  availability_zone = "eu-central-1c"
}

resource "aws_subnet" "bc2" {
  vpc_id            = aws_vpc.b.id
  cidr_block        = "10.101.103.0/24"
  availability_zone = "eu-central-1c"
}

output "vpc_id_this" {
  value = aws_vpc.a.id
}

output "subnet_ids_this" {
  value = [
    aws_subnet.aa.id,
    aws_subnet.ab.id,
    aws_subnet.ac.id,
  ]
}

output "subnet_ids_this_duplicate_az" {
  value = [
    aws_subnet.ac2.id,
  ]
}

output "vpc_id_other" {
  value = aws_vpc.b.id
}

output "subnet_ids_other" {
  value = [
    aws_subnet.ba.id,
    aws_subnet.bb.id,
    aws_subnet.bc.id,
  ]
}

output "subnet_ids_other_duplicate_az" {
  value = [
    aws_subnet.bc2.id,
  ]
}
