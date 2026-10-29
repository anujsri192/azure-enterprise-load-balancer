<div align="center">

# ⚖️ Azure Enterprise Load Balancer Infrastructure (IaC)
### Production Standard Public & Internal Load Balancers with Outbound SNAT

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure Provider](https://img.shields.io/badge/AzureRM-~%3E3.90-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
[![Availability](https://img.shields.io/badge/SLA-99.99%25%20Zone%20Redundant-00C853?style=for-the-badge&logo=shield&logoColor=white)](https://learn.microsoft.com/azure/load-balancer/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

<p align="center">
  <strong>Architected & Maintained by <a href="https://github.com/anujsri192">Anuj Srivastava</a> — Lead DevSecOps Architect</strong>
</p>

</div>

---

## 📌 Overview & Production Architecture

This repository delivers an enterprise-grade Terraform module and orchestration environment for **Azure Standard Load Balancer (Public & Internal)** implementations:

- **Public Standard Load Balancer**: Zone-redundant frontend public IP (`zones = ["1", "2", "3"]`), HTTPS health probes, zero-loss TCP connection reset, and dynamic outbound SNAT rules.
- **Internal Standard Load Balancer**: Private IP frontend (`snet-internal-lb`) for intra-VNet microservice traffic distribution and zero direct public exposure.
- **Dynamic Frontend Configurations**: HCL `dynamic "frontend_ip_configuration"` blocks for seamless multi-IP / multi-subnet scaling.
- **Child-Parent Module Hierarchy**: Reusable `modules/load_balancer` called from `environments/prod`.

---

## 🏛️ Repository Structure

```bash
azure-enterprise-load-balancer/
├── .github/
│   └── workflows/
│       └── terraform-ci.yml       # GitHub Actions CI for fmt and validation
├── modules/
│   └── load_balancer/             # Standard Load Balancer child module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   └── prod/                      # Parent orchestration module (Public + Internal LB)
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── outputs.tf
│       ├── versions.tf
│       └── provider.tf
├── .gitignore
├── LICENSE
└── README.md
```

---

## 🚀 Quickstart Runbook

```bash
cd environments/prod
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply -auto-approve
```

---

## 👨‍💻 Author

**Anuj Srivastava**
- **Role**: Lead DevSecOps Architect & Enterprise Cloud Systems Engineer
- **GitHub**: [@anujsri192](https://github.com/anujsri192)
- **LinkedIn**: [Anuj Srivastava](https://www.linkedin.com/in/anujsri192)

