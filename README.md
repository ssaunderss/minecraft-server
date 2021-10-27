# minecraft-server

Want to create your own minecraft server without paying for a realm (by potentially spending more on AWS)? Looking for a self-hosted, overkill minecraft server solution to impress your friends? Maybe you want to learn more about DevOps with a fun example? Look no further! 

## Requirements
1. Terraform (will also use Terraform Cloud in this writeup for deploying)
2. AWS account 

## Todos:
- [X] Base Terraform code for creating a minecraft server
- [X] Run automated backups of the server
- [ ] Take care of breaking Terraform v0.13 issues
- [ ] Offload backups from server to s3 before purging, add s3 to Terraform code
- [ ] Add Terraform code for micro EC2 server that hosts below Elixir GenServer
- [ ] Create Elixir GenServer that takes care of automatic startup / shutdown of mc server (fun alternative to AWS Lambda to get some more hands on with Elixir)
- [ ] Post Provisioning is already complicated and will get more complicated so migrate to Ansible or Puppet

