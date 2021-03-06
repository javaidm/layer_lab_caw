tools =  params.globals.tools
workflow wf_savvy_cnv_somatic{
    take: _bam_recal
    main:
     /* SavvyCNV Somatic Copy Number related calls */
    /* Starting point is duplicated marked bams from MarkDuplicates.out.marked_bams with the following structure */
    /* MarkDuplicates.out.marked_bams => [idPatient, idSample, md.bam, md.bam.bai]*/
    SavvyCNVCoverageSummary(_bam_recal)
    SavvyCNV(SavvyCNVCoverageSummary.out.collect())
} // end of wf_germline_cnv


// /* SavvyCNV Related processes */

process SavvyCNVCoverageSummary {
    label 'container_llab'
   label 'cpus_16'
    tag "${idSample}"
    cache false
    // publishDir "${params.outdir}/VariantCalling/${idSample}/SavvycnvCoverageSummary", mode: params.publish_dir_mode
    
    input:
         tuple idPatient, idSample, file(bam), file(bai)
    
    output:
    file("${idSample}.coverageBinner")

    when: 'savvy_cnv_somatic' in tools

    script:
    
    """
    init.sh
    java -Xmx1g CoverageBinner ${bam} > ${idSample}.coverageBinner
    """
}

process SavvyCNV {
    label 'container_llab'
    label 'cpus_16'
    // tag "${idSample}"
    publishDir "${params.outdir}/VariantCalling/", mode: params.publish_dir_mode
    
    input:
        file("*")
    
    output:
        file("SavvycnvResults")
    
    when: 'savvy_cnv_somatic' in tools
    
    script:
    chunk_size = 200000
    
    """
    init.sh
    mkdir -p SavvycnvResults/SavvycnvCoverageSummary
    mkdir  SavvycnvResults/pdfs
    java -Xmx30g SavvyCNV -a -d ${chunk_size} *.coverageBinner > cnv_list.csv 2>log_messages.txt
    cp *.coverageBinner SavvycnvResults/SavvycnvCoverageSummary/
    cp *.cnvs.pdf SavvycnvResults/pdfs
    cp cnv_list.csv log_messages.txt SavvycnvResults/
    """
}