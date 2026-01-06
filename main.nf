#!/usr/bin/env nextflow

params.input = "test-input"
OutputDir = params.outdir
params.pipeline_info = "test-pipeline-info"

process TEST {
    container 'ubuntu:22.04'
    
    output:
    path 'bams'

    script:
    """
    mkdir -p bams
    echo "Test complete" > bams/test_file.txt
    """
}

workflow {
    main:
    ch_test_output = TEST()

    publish:
    bams = ch_test_output
}

output {
    
    bams {
        path 'bams'
    }
}