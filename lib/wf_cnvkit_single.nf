tools = params.globals.tools
workflow wf_cnvkit_cnv_single_sample_mode{
    take: _md_bam_collected
    take: _fasta
    take: _target_bed
    main:
     /* CNVKit Somatic Copy Number related calls */
    /* Starting point is duplicated marked bams from MarkDuplicates.out.marked_bams with the following structure */
    /* MarkDuplicates.out.marked_bams => [idPatient, idSample, md.bam, md.bam.bai]*/
        CNVKitSingle(
            _md_bam_collected,
            _fasta,
            _target_bed)
} // end of wf_germline_cnv


process CNVKitSingle{
    label 'cpus_8'
    label 'container_llab'
    publishDir "${params.outdir}/VariantCalling/${idSample}/CNVKit", mode: params.publish_dir_mode
    
    input:
        tuple idPatient, idSample, file(bam), file(bai)
        file(fasta)
        file(fastaFai)
        file(cnvkit_ref)
        // file(targetBED)
    
    output:
    tuple val("cnvkit_single"), idPatient, idSample, file("*")

    when: params.cnvkit_ref && 'cnvkit_single' in tools

    script:
    
    """
    init.sh
    cnvkit.py batch ${bam} \
        --reference ${cnvkit_ref} \
        --scatter \
        --diagram
    """
}