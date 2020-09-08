# NGINX PROJECT

O projeto foi construido usando Terraform para a infraestrutura, Docker para criar a imagem  com seu respectivo arquivo de configuração e orquestrado pelo Gitlab CI. Com isso existem dois modos de criar o projeto em si, o primeiro e que considero de boa prática é deixar a cargo do proprio CI, porém pode-se também criar localmente.

## ENVIRONMENTS
Algumas variaveis precisam ser setadas tanto no Gitlab UI quanto localmente.

```
ACCOUNT (AWS ACCOUNT)
PROD_AWS_ACCESS_KEY_ID
PROD_AWS_SECRET_ACCESS_KEY
```

##  USAGE

Veja como invocar este módulo de exemplo em seus projetos, no caso aqui, é usado o mod local, entretanto o modo mais indicado é colocando o caminho http no source:

```hcl
module "ecs_cluster" {
    source = "../../modules/ecs-cluster"
    team   = "foo"
    capacity_providers = xxx
    tags = {
        team        = "squad-foo"
        Billing     = "squad-foo"
        Project     = "foo-project"
        Application = "infra"
        Environment = "prod"
    }
}

module "ecs_capacity_provider" {
  source          = "../../modules/ecs-cp"
  ecs_cluster     = "foo"
  name            = "t2-micro"
  instace_type    = "t2.micro"
  max_size        = 3
  min_size        = 1
  target_capacity = 2
  network = {
    vpc             = "vpc-xxx"
    subnets         = ["subnet-xxx", "subnet-xxx", "subnet-xxx", "subnet-xxx"]
    security_groups = ["sg-xxx"]
  }
  tags = {
    team        = "squad-foo"
    project     = "infra"
    service     = "ecs"
    Application = "ecs/squad-foo"
    Billing     = "ecs/squad-foo"
    Environment = "production"
    Name        = "ecs/squad-foo"
    Provisioner = "terraform"
  }

  asg_tags = [
    {
      key                 = "team"
      value               = "squad-foo"
      propagate_at_launch = true
    },
    {
      key                 = "project"
      value               = "infra"
      propagate_at_launch = true
    },
    {
      key                 = "service"
      value               = "ecs"
      propagate_at_launch = true
    },
    {
      key                 = "Application"
      value               = "ecs/squad-foo"
      propagate_at_launch = true
    },
    {
      key                 = "Billing"
      value               = "ecs/squad-foo"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "production"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "ecs/squad-foo"
      propagate_at_launch = true
    },
    {
      key                 = "Provisioner"
      value               = "terraform"
      propagate_at_launch = true
    }
  ]
}

module "ecr_proxy_nginx" {
  source = "../../modules/ecr"

  team          =  "squad-foo"
  application   =  "nginx-proxy"
  tags = {
    team        = "squad-foo"
    Billing     = "squad-foo"
    Project     = "foo-project"
    Application = "infra"
    Environment = "prod"
  }

}

module "ecs_service" {
  source  = "../../modules/ecs-service"
  cluster = "foo"
  application = {
    name        = "nginx"
    version     = "01"
    environment = "prod"
  }
  container = {
    image  = "xxx.dkr.ecr.region.amazonaws.com/${var.team}/${var.application}:latest"
    cpu    = 256
    memory = 512
    port   = 8080
  }
  scale = {
    cpu = 90
    min = 1
    max = 2
  }
  config = {
    environment = []
  }
  network = {
    vpc             = "vpc-xxx"
    subnets         = ["subnet-xxx", "subnet-xxx", "subnet-xxx", "subnet-xxx"]
    security_groups = ["sg-xxx"]
  }
  service_policy = "policy/policy.tpl.json"
  tags = {
    "team"    = "squad-foo"
    "project" = "foo-project"
    "service" = "reverse_proxy"
  }
  capacity_provider = "xxx"

  alb = {
    enable             = true
    public             = true
    certificate_domain = "web-foo.com"
    idle_timeout       = 300
    health             = "/health"
    subnets            = ["subnet-xxx", "subnet-xxx", "subnet-xxx", "subnet-xxx"]
    security_groups    = ["sg-xxx"]
  }
}
```

## USAGE LOCAL

```
make infra_init
make infra_apply
```

## OBS.

1. Em todos os casos, as variáveis mencionadas no primeiro passo, devem ser setadas.
2. O seu arquivo main.tf onde ira ser feito a chamada dos módulos, deve ser criada no diretório: infra/environments/ecs-prod.
3. O sufixo de environments (dev / stage / prod) não foi criado para esta versão, porém, pode ser feita rapidamente para a próxima tag.