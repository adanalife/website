
# Welcome to the Website

Live site available here: [https://www.dana.lol](http://www.dana.lol)

```
                                                 _..-,--.._
                                           ,`. ,',','      `.
                                           `. `,/`/          \
                                             :'.`:            :
                  ____ _          _ __       | |`|            |
                _(    `.)        ( (  )`.    : `-'            ;     _
               ( (    ) ))      ( (    ))    ,\_            _/.  (`','
              ( (   )  _)        `-(__.'    '.  ```------'''  .`
               '.__)--'       .-..           |``-...____...-''|
                             (_)_))          |                |
                        ,'`.        ___...---|                |--..._
            ,'`. ,'`. ,'   _`.---'''         |                | "
          -'..._`.   `.   /`-._  "      "    |    _           |
                 ```-..`./:::::)             `-...||______...-'    "
                        /:::_.'     "        "                "
                     _.:.'''   "                       "
```

### CloudFormation

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

