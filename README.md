[![Version](https://img.shields.io/github/v/release/dmerrick/website?sort=semver&include_prereleases)](https://github.com/dmerrick/website/releases)
[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fdmerrick%2Fwebsite%2Fbadge&style=flat)](https://actions-badge.atrox.dev/dmerrick/website/goto)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

Live site available here: [https://www.dana.lol](http://www.dana.lol)

If you want you can read these two articles about how the site works: [part 1](https://www.dana.lol/2017/10/01/how-this-site-works) and [part 2](https://www.dana.lol/2017/10/12/how-this-site-works-p-2).


### Contact Form

The site is designed to be static, but there is a small app that runs [the contact page](https://www.dana.lol/contact). You can view the code that runs the contact page in the [`danalol-contact-form` project](https://github.com/dmerrick/danalol-contact-form).


### Technical Infrastructure

To build out the infrastructure required to run this site, you can use the CloudFormation templates found in `cloudformation/`

You will need domain name (like `example.com`), a blog domain name (like `www.example.com`), and an AWS ACM Certificate ARN string.
```
# create the hosted zone in Route53
aws cloudformation create-stack \
  --stack-name <<ROUTE53 STACK NAME>> \
  --template-body file://./cloudformation/route53-zone.yaml \
  --parameters ParameterKey=DomainName,ParameterValue=<<EXAMPLE.COM>>

# create the S3 bucket and CloudFront setup
aws cloudformation create-stack \
  --stack-name <<CDN STACK NAME>> \
  --template-body file://./cloudformation/s3-static-website-with-cloudfront-and-route-53.yaml \
  --parameters \
      ParameterKey=DomainName,ParameterValue=<<EXAMPLE.COM>> \
      ParameterKey=FullDomainName,ParameterValue=<<WWW.EXAMPLE.COM>> \
      ParameterKey=AcmCertificateArn,ParameterValue=<<ACM ARN STRING>>
```
