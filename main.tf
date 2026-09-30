module "network" {
    source = "./modules/networking"
}

module "compute" {
    source = "./modules/compute"
    security_group = module.network.instance_security_group_id
    subnet_ids = module.network.subnet_ids
}

module "load_balancer" {
    source = "./modules/load-balancer"
    vpc_id = module.network.vpc_id
    security_group = module.network.alb_security_group_id
    subnet_ids = module.network.subnet_ids
    instance_id = module.compute.instance_id
}