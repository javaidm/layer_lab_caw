tools = params.globals.tools
step = params.step

workflow wf_mark_duplicates{
    take: _bams
    main:
        MarkDuplicates(_bams)
    emit:
        dm_bams = MarkDuplicates.out.marked_bams
}


process MarkDuplicates {
    label 'cpus_max'
    tag {idPatient + "-" + idSample}

    publishDir "${params.outdir}/Preprocessing/${idSample}/DuplicateMarked/", mode: params.publish_dir_mode

    input:
        tuple idPatient, idSample, file("${idSample}.bam"), file("${idSample}.bai")

    output:
        tuple idPatient, idSample, file("${idSample}.md.bam"), file("${idSample}.md.bai"), emit: marked_bams
        // file ("${idSample}.bam.metrics")

    // when: !(step in ['recalibrate', 'variantcalling', 'annotate'])
    when: step  ==  'mapping'

    script:
    """
    init.sh
    samtools sort -n --threads ${task.cpus}  -O SAM  ${idSample}.bam | \
        samblaster -M --ignoreUnmated| \
        samtools sort --threads ${task.cpus}  -O BAM > ${idSample}.md.bam

    samtools index ${idSample}.md.bam && \
        mv ${idSample}.md.bam.bai ${idSample}.md.bai
    """
}