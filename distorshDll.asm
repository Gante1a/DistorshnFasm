include '.\MZERO.inc'

format PE DLL  
entry DllEntryPoint

	macro дисторшн размер, массив, значение, операция, выход_за_предел, неправильный_знак {
			pusha
			xor esi, esi ;обнуление esi
			mov edx, [выход_за_предел]
			mov ebx, [размер]
		начало_цикла:
			cmp esi, ebx ; если входная строка закончилась, выходим
		je конец_цикла
			mov ecx, [массив]
			mov ah, 0 ; Очистим регистр ah  
			mov al, [ecx + esi] ; записываем первое число в регистр

			cmp [операция], '+' ; сравниваем с операцией '+'
		je сумма
			cmp [операция], '-' ; сравниваем с операцией '-'
		je вычитание
			cmp [операция], '*' ; сравниваем с операцией '*'
		je умножение
		jmp ошибка

		сумма:
			add al, byte [значение]
			; sub al, 100
			adc ah, 0  
			cmp ah, 1 
		jae замена_с_FF ; Если больше или равно FF, перейти к замене
		jmp конец_вычислений

		вычитание:
			sub al, byte [значение]
			adc ah, 0 
			cmp ah, 1 
		jae замена_с_00 ; Если больше или равно 00, перейти к замене
		jmp конец_вычислений

		умножение:
			mul byte [значение] 
			adc ah, 0 
			cmp ah, 1 
		jae замена_с_FF ; Если больше или равно FF, перейти к замене
		jmp конец_вычислений
			
		замена_с_FF:
			mov al, 0xFF 
			mov ah, 0x00 
			mov dword [edx], 1
			jmp конец_вычислений
			
		замена_с_00:
			mov al, 0x00 
			mov ah, 0x00 
			mov dword [edx], 1
		jmp конец_вычислений

		конец_вычислений:
			mov byte [ecx + esi], al ; записываем 1 число в массив
			add esi, 4
		jmp начало_цикла
			
		ошибка:
			mov eax, [неправильный_знак]
			mov dword [eax], 1	
		конец_цикла:
			popa
	}

    section '.proc' code readable writeable executable
	
	proc DllEntryPoint hinstDLL,fdwReason,lpvReserved
		mov	eax,TRUE
		ret
	endp
	
    proc Distorshn размер, массив, значение, операция, выход_за_предел, неправильный_знак
		дисторшн размер, массив, значение, операция, выход_за_предел, неправильный_знак
		ret
	endp

    section '.export' export readable
        export 'distorshDll.dll',\
                Distorshn, 'Distorshn'

	section '.reloc' fixups data readable discardable 
		if $=$$
			dd 0, 8
		end if	