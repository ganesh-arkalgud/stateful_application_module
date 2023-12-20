output "node_iam_role_name" {
  value = aws_iam_role.node_role.name
}

output "asg_names" {
  value = [for node_id, module_output in module.cluster_nodes: module_output.asg_name]
}

output "node_userdata_script" {
  value = module.cluster_nodes.node_userdata_script
}
