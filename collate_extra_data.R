library(data.table)
library(plyr)

sc_metadata <- list(
	breast_qian = quote(
		fread('../data_and_figures/qian_breast_2020_reclassified.csv')[
			cell_type != 'ambiguous' & id != 'sc5rJUQ064_CCATGTCCATCCCATC',
			-c('patient', 'cell_type_author', 'cell_type_lenient')
		]
	),
	crc_lee_smc = quote(
		fread('../data_and_figures/lee_crc_2020_smc_reclassified.csv')[
			cell_type != 'ambiguous',
			-c('patient', 'cell_type_author', 'cell_type_lenient')
		]
	),
	hnscc_puram = quote(
		fread('../data_and_figures/puram_hnscc_2017_reclassified.csv')[
			cell_type != 'ambiguous',
			-c('patient', 'cell_type_author')
		]
	),
	liver_ma = quote(
		fread('../data_and_figures/ma_liver_2019_reclassified.csv')[
			cell_type != 'ambiguous',
			-c('patient', 'cell_type_author', 'cell_type_lenient')
		]
	),
	luad_kim = quote(
		fread('../data_and_figures/kim_luad_2020_reclassified.csv')[
			cell_type != 'ambiguous',
			-c('patient', 'cell_type_author')
		]
	),
	lusc_qian = quote(
		fread('../data_and_figures/qian_lung_2020_reclassified.csv')[
			disease == 'LUSC' & cell_type != 'ambiguous',
			-c('patient', 'disease', 'cell_type_author', 'cell_type_lenient')
		]
	),
	ovarian_qian = quote(
		fread('../data_and_figures/qian_ovarian_2020_reclassified.csv')[
			cell_type != 'ambiguous' & !(id %in% c('scrSOL001_TCATTTGTCTGTCAAG', 'scrSOL004_TTGCCGTTCTCCTATA')),
			-c('patient', 'cell_type_author', 'cell_type_lenient')
		]
	),
	pdac_peng = quote(
		fread('../data_and_figures/peng_pdac_2019_reclassified.csv')[
			cell_type != 'ambiguous' & !(id %in% c('T8_TGGTTCCTCGCATGGC', 'T17_CGTGTAACAGTACACT')),
			-c('patient', 'cell_type_author')
		]
	)
)

extra_data <- rbindlist(
    lapply(
        names(sc_metadata),
        function(ref) {
			cat(paste0(ref, '\n'))
			sc_data <- eval(sc_metadata[[ref]])
			sc_diff <- sc_data[cell_type == 'cancer', colMeans(.SD), .SDcols = -c('id', 'cell_type')] -
				sc_data[cell_type == 'caf', colMeans(.SD), .SDcols = -c('id', 'cell_type')]
			cat('\tDone!\n')
			data.table(source = ref, gene = names(sc_diff), diff = sc_diff)
        }
    )
)

fwrite(extra_data, '../data_and_figures/collated_extra_data.csv')
