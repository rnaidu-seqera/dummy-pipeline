#!/usr/bin/env nextflow

/*
 * Simple Hello World Pipeline
 * Tests basic Nextflow execution on Seqera Platform
 */

params.greeting = "Hello World"

process sayHello {
    debug true

    output:
    path "hello.txt"

    script:
    """
    echo "${params.greeting} from Nextflow!" | tee hello.txt
    echo "Pipeline executed successfully at \$(date)"
    echo "Running on: \${HOSTNAME}"
    echo "Nextflow version: ${workflow.nextflow.version}"
    """
}

workflow {
    sayHello()

    sayHello.out.view { "Created output file: $it" }
}

workflow.onComplete {
    println "Pipeline completed!"
    println "Status: ${workflow.success ? 'SUCCESS' : 'FAILED'}"
    println "Duration: ${workflow.duration}"
}
