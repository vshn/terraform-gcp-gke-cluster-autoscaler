# Changelog

## v2.0.0

- Remove variables
  - `worker_asg_min_size`
  - `worker_asg_max_size`
  - `instance_group_urls`
- Add `autoscaling_groups` variable

## v1.4.1

- Remove ImageVersion variable since its not required anymore

## v1.4.0

- Dynamically set instance groups based on input

## v1.3.2

- Remove unused variable "worker_asg_prefix"

## v1.3.1

- Adjust AutoscalingGroupPrefix to correct variable (once more, oopsie daisy!)

## v1.3.0

- Adjust AutoscalingGroupPrefix to correct variable

## v1.2.0

- Fix k8s SA Binding

## v1.1.0

- Fix Typos

## v1.0.0

- Initial release
