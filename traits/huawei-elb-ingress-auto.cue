"huawei-elb-ingress-auto": {
	alias: ""
	annotations: {}
	attributes: {
		appliesToWorkloads: ["deployments.apps", "statefulsets.apps"]
		podDisruptive: false
	}
	labels: {}
	type: "trait"
}

template: {
	outputs: ingress: {
		apiVersion: "networking.k8s.io/v1"
		kind:       "Ingress"
		metadata: {
			name: context.name
			annotations: {
				"kubernetes.io/elb.class":      "performance"
				"kubernetes.io/elb.port":       "80"
				"kubernetes.io/elb.autocreate": "{ \"type\": \"public\", \"bandwidth_name\": \"cce-bandwidth-poc5\", \"bandwidth_chargemode\": \"bandwidth\", \"bandwidth_size\": 5, \"bandwidth_sharetype\": \"PER\", \"eip_type\": \"5_bgp\", \"available_zone\": [ \"(parameter.available_zone)\" ], \"l7_flavor_name\": \"L7_flavor.elb.s1.small\" }"
			}
		}
		spec: {
			ingressClassName: parameter.class
			rules: [{
				if parameter.domain != _|_ {
					host: parameter.domain
				}
				http: paths: [
					for k, v in parameter.http {
						path:     k
						pathType: "ImplementationSpecific"
						backend: {
							service: {
								name: context.outputs.webserviceExpose.metadata.name
								port: number: v
							}
						}
					},
				]
			}]
		}
	}
	parameter: {
                available_zone: string

		// +usage=Specify the domain you want to expose
		domain?: string

		// +usage=Specify the mapping relationship between the http path and the workload port
		http: [string]: int

		// +usage=Specify the class of ingress to use
		class: *"cce" | string
	}
}
