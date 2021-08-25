



MEMORY {

	/*mem : ORIGIN = 0x00000000, LENGTH = 0x0000fffc*/
	mem : ORIGIN = 0x00000000, LENGTH = 0x0007ffc
	data  :  ORIGIN = 0x8000,LENGTH = 0x0007ffc

}

SECTIONS {
	.text : {
		/*. = 0x000000;*/
		start*(.text);
		main*(.text);
		*(.text)
		end = .;
		. = ALIGN(4);
	} > mem

	.data : {
		*(*);
		end = .;
		. = ALIGN(4);
	} > data
}






/* mcore

SECTIONS {
	.memory : {
		. = 0x000000;
		start*(.text);
		main*(.text);
		*(*);
		end = .;
	}
	.comment : {
		.=0x0fc4;
		*(.comment);
		end=.;
	}

}

*/