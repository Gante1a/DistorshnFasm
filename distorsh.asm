include '.\MZERO.inc'

format PE console
entry start

section '.data' data readable writeable
    нач_название db 'ST2.uni',0
    массив dd 1  
    размер dd 0 
    нач_файл dd 0
	значение dd 0x5A
	операция dd '-' ; + сложение     - вычитание      * умножение
	выход_за_предел dd 0
	консоль dd 0
	неправильный_знак dd 0
	успешное_сообщение db 'Programma vipolnena yspeshno', 0
	ошибочное_сообщение db 'gde-to oshibka', 0
	сообщение_выхода_за_предел db 'proizoshol vihod za predel, obratite vnimanie', 0x0A, 0

    кон_название db 'result.txt',0
    кон_файл dd 0 

		section '.code' code readable executable
		start:
		mov eax, метка_для_td32
		
		invoke GetStdHandle, STD_OUTPUT_HANDLE
			
					mov [консоль], eax
  
        invoke CreateFile, нач_название, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0 ;открытие файла 
		
					cmp eax, INVALID_HANDLE_VALUE
                je ошибка
                
					mov [нач_файл], eax

        invoke GetFileSize, [нач_файл], 0 ;получение размера файла
		
					cmp eax, 0xffffffff
                je ошибка 
					test eax, 3
				jnz ошибка	
					mov [размер], eax                                             
				
        invoke VirtualAlloc, 0, [размер], MEM_COMMIT, PAGE_READWRITE ;выделение виртуальной памяти
		
					cmp eax, 0
                je ошибка
					mov [массив], eax		
				
        invoke ReadFile, [нач_файл], [массив], [размер], 0, 0 ;чтение файла
		
					cmp eax, 0
				je ошибка

        invoke CloseHandle, [нач_файл] ;закрытие файла	

		метка_для_td32:
        invoke Distorshn, [размер], [массив], [значение], [операция], выход_за_предел, неправильный_знак ;вызов длл
		
					mov ecx, [неправильный_знак]
					cmp ecx, 1
				je ошибка	
					mov edx, [выход_за_предел]
					cmp edx, 1
				jne случай_выхода	
					mov esi, сообщение_выхода_за_предел
					xor ecx, ecx
					начало_предела:
					cmp byte [esi + ecx], 0
				je конец_предела
					inc ecx
				jmp начало_предела
				конец_предела:
			
		invoke WriteConsole, [консоль], сообщение_выхода_за_предел, ecx, 0, 0, 0
		
				случай_выхода:
    
        invoke CreateFile, кон_название, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL ;создание файла
		
					cmp eax, INVALID_HANDLE_VALUE
				je ошибка
					mov [кон_файл], eax 
				
        invoke WriteFile, [кон_файл], [массив], [размер], 0, 0 ;запись данных в файл
		
        invoke CloseHandle, [кон_файл] ;закрытие файла
		
					mov esi, успешное_сообщение
					xor ecx, ecx
				начало_успеха:
					cmp byte [esi + ecx], 0
				je конец_успеха
					inc ecx
				jmp начало_успеха
				конец_успеха:
				
		invoke WriteConsole, [консоль], успешное_сообщение, ecx, 0, 0, 0
				jmp метка
		
		; invoke CloseHandle, [консоль]
		
        ; invoke ExitProcess, 0

				ошибка:
					mov esi, ошибочное_сообщение
					xor ecx, ecx
				начало_ошибки:
					cmp byte [esi + ecx], 0
				je конец_ошибки
					inc ecx
				jmp начало_ошибки
				конец_ошибки:
			
		invoke WriteConsole, [консоль], ошибочное_сообщение, ecx, 0, 0, 0
		
				метка:
		
		invoke CloseHandle, [консоль]
		
		invoke GetLastError
		
		invoke ExitProcess, eax

        section '.import' import data readable ;сегмент импорта
        library kernel, 'kernel32.dll',\
        myDll, 'distorshDll.dll'
        import kernel,\
        CreateFile, 'CreateFileA',\
        ReadFile, 'ReadFile',\
        WriteFile, 'WriteFile',\
        GetFileSize, 'GetFileSize',\
        VirtualAlloc, 'VirtualAlloc',\
        CloseHandle, 'CloseHandle',\
        WriteConsole, 'WriteConsoleA',\
        GetStdHandle, 'GetStdHandle',\
        GetLastError, 'GetLastError',\
        ExitProcess, 'ExitProcess'
        import myDll,\
        Distorshn, 'Distorshn'