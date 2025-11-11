#!/usr/bin/env nextflow

/*
 * EFS/FSx Mount Testing Pipeline
 * Tests whether EFS/FSx volumes are properly mounted at /staging/scratch
 */

params.efs_file_system_id = "fs-030e6f671ce998fa2"  // EFS filesystem ID
params.mount_path = "/staging/scratch"                // Intended mount location

process testEFSMount {
    debug true
    container 'ubuntu:22.04'

    script:
    """
    echo "======================================================================"
    echo "EFS/FSx Mount Test"
    echo "======================================================================"
    echo "Testing mount path: ${params.mount_path}"
    echo "EFS Filesystem ID: ${params.efs_file_system_id}"
    echo ""

    echo "=== 1. Checking if ${params.mount_path} exists ==="
    if [ -d "${params.mount_path}" ]; then
        echo "✓ Directory exists"
        ls -la ${params.mount_path} || true
    else
        echo "✗ Directory does NOT exist"
        echo "Creating directory..."
        mkdir -p ${params.mount_path}
    fi
    echo ""

    echo "=== 2. Checking what filesystem type is at ${params.mount_path} ==="
    df -T ${params.mount_path}
    echo ""

    FSTYPE=\$(df -T ${params.mount_path} | tail -1 | awk '{print \$2}')
    echo "Filesystem type: \$FSTYPE"

    if [ "\$FSTYPE" = "nfs4" ] || [ "\$FSTYPE" = "nfs" ]; then
        echo "✓ This is NFS (EFS/FSx) - MOUNT IS WORKING!"
    elif [ "\$FSTYPE" = "ext4" ] || [ "\$FSTYPE" = "xfs" ]; then
        echo "✗ This is \$FSTYPE (EBS volume) - MOUNT IS NOT WORKING!"
        echo "   Data is being written to the root/EBS volume, not EFS/FSx"
    else
        echo "⚠ Unknown filesystem type: \$FSTYPE"
    fi
    echo ""

    echo "=== 3. Checking all mounted filesystems ==="
    mount | grep -E '(staging|efs|fsx)' || echo "No staging/EFS/FSx mounts found"
    echo ""

    echo "=== 4. Full mount table ==="
    mount
    echo ""

    echo "=== 5. Disk usage for ${params.mount_path} ==="
    df -h ${params.mount_path}
    echo ""

    echo "=== 6. Attempting to write test file ==="
    TEST_FILE="${params.mount_path}/test_\${HOSTNAME}_\$(date +%s).txt"
    echo "Test file written at \$(date)" > \$TEST_FILE

    if [ -f "\$TEST_FILE" ]; then
        echo "✓ Successfully wrote: \$TEST_FILE"
        cat \$TEST_FILE

        # Check where it actually went
        echo ""
        echo "File details:"
        ls -lh \$TEST_FILE
        df -h \$TEST_FILE
    else
        echo "✗ Failed to write test file"
    fi
    echo ""

    echo "=== 7. Root volume disk usage (for comparison) ==="
    df -h /
    echo ""

    echo "======================================================================"
    echo "SUMMARY"
    echo "======================================================================"
    echo "Mount path: ${params.mount_path}"
    echo "Filesystem type: \$FSTYPE"

    if [ "\$FSTYPE" = "nfs4" ] || [ "\$FSTYPE" = "nfs" ]; then
        echo "Result: ✓ EFS/FSx IS mounted correctly"
    else
        echo "Result: ✗ EFS/FSx is NOT mounted - using EBS volume"
        echo ""
        echo "Issue observed:"
        echo "- Directory exists but EFS/FSx is not mounted"
        echo "- Data goes to root EBS volume instead of shared storage"
    fi
    echo "======================================================================"
    """
}

workflow {
    testEFSMount()
}

workflow.onComplete {
    println ""
    println "======================================================================"
    println "Pipeline completed!"
    println "======================================================================"
    println "Status: ${workflow.success ? 'SUCCESS' : 'FAILED'}"
    println "Check the output above to see if EFS/FSx is mounted correctly"
    println "======================================================================"
}
