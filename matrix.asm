; .:: MATRIS CARPICI ::.
; 
; m*n'lik bir matrisle, n'lik bir matris carpar
; sonucu ekrana yazdirir.
;
; Bu programda;
; m = matrisin kolon sayisini belirtir
; n = matrisin satir sayisini belirtir
;
; Kodda kullanilan TAB boslugu = 4 'tur
;
; MASM ile derleyiniz.
;
; Omer Akyol -- Temmuz 2008



.model small
.stack

.data
girisMsj		byte "...:::: MATRIS CARPICI ::::...", 0dh, 0ah, 0dh, 0ah, '$'
aciklamaMsj		byte "m x n 'lik matris icin, m ve n 'i giriniz.", 0dh, 0ah, '$'
aciklamaMsj2	byte "Carpilcak matrisin n'i ilk matrisin m'i ile ayni olmalidir", 0dh, 0ah, '$'
aciklamaMsj3	byte "O yuzden carpilcak matisin n =", '$'
aciklamaMsj4	byte "Carpilcak matris icin, m'i giriniz.", 0dh, 0ah, '$'
aciklamaMsj5	byte 0dh, 0ah, "Programi sonlandirmak icin ENTER'a basiniz.", '$'
mgirMsj			byte "m'i giriniz:", '$'
ngirMsj			byte "n'i giriniz:", '$'
enterMsj		byte 0dh, 0ah, '$'
matrisMsj		byte "MATRIS1",'$'
matrisMsj2		byte "MATRIS1:",'$'
matrisMsj3		byte "MATRIS2",'$'
matrisMsj4		byte "MATRIS2:",'$'
sonucMsj		byte "SONUC MATRIS:",'$'
acMsj			byte "[", '$'
kapaMsj			byte "]", '$'
girinizMsj		byte " giriniz:",'$'
virgulMsj		byte ",",'$'
backMsj			byte 8d, '$'
debugMsj		byte "debug mesaji", 0dh, 0ah, '$'	; Debug yaparken kullanilan mesaj


matris1		word 1000 DUP (?)	; m x n 'lik matris
matris2		word 1000 DUP (?)	; n'lik carpilcak olan matris
sonucMatris	word 1000 DUP (?)	; sonucun yazilacagi matris

mdegeri		word 0	; m x n'lik matrisin m degeri
mdegeri2	word 0	; n'lik matrisin m degeri
ndegeri		word 0	; m x n'lik matrisin n degeri
ndegeri2	word 0	; n'lik matrisin n degeri
sayi		word 0	; 16'bitlik sayi
matrisBoy	word 0	; m x n, matristeki eleman sayisi
xdeger		word 0	; matris kolon dolasirken kullanilan degisken
ydeger		word 0	; matris satir dolasirken kullanilan degisken

buffer		byte ?	; Karakter okumalarda kullaniliyor
negatif		byte 0	; 0: sayý pozitif. 1: sayi negatif
sifirBit	byte 0	; Binary -> ASCII donusumunda gerekli


.code

main proc 
	mov ax, @data	; 16 bit mode oldugu icin gerekli
	mov ds, ax		; ds'ye direk @data koyulamaz. 
	
	;******************************** INPUT - GIRIS ISLEMLERI ***********************************;
	
	mov dx, offset girisMsj
	call mesaj_goster
	
	mov	dx, offset aciklamaMsj
	call mesaj_goster

	; MxN lik matris icin M'i oku
	mov dx, offset mgirMsj
	call mesaj_goster
	call sayi_oku
	mov ax, sayi
	mov mdegeri, ax
	
	; Satir atla
	mov dx, offset enterMsj
	call mesaj_goster
	
	; MxN'lik matris icin N'i oku
	mov dx, offset ngirMsj
	call mesaj_goster
	call sayi_oku
	mov ax, sayi
	mov ndegeri, ax
	
	; Matris boy hesapla
	mov ax, mdegeri
	mul ndegeri
	mov matrisBoy, ax			; matrisBoy = mdegeri x ndegeri
	
	call matris_doldur			; 1. Matris kullanicidan iste ve doldur
	
	call matris_goster			; 1. Matris icerigini matris seklinde goster
	
	
	; N'lik matris icin N'i oku
	; ve gerekli aciklamalari yap
	mov dx, offset enterMsj
	call mesaj_goster
	mov dx, offset aciklamaMsj2
	call mesaj_goster
	mov dx, offset aciklamaMsj3
	call mesaj_goster
	mov ax, mdegeri
	mov sayi, ax
	call sayi_yaz
	mov dx, offset enterMsj
	call mesaj_goster
	mov dx, offset aciklamaMsj4
	call mesaj_goster
	mov dx, offset mgirMsj
	call mesaj_goster
	call sayi_oku
	mov ax, sayi
	mov mdegeri2, ax
	mov ax, mdegeri				; 1. Matrisin m'i ile carpilcak 
	mov ndegeri2, ax			; olan matrisin n'i esit olmali
	
	call matris_doldur2			; 2. Matris kullanicidan iste ve doldur
	
	call matris_goster2			; 2. Matris icerigini matris seklinde goster
	
	
	
	;******************************** CARPMA ISLEMI ***********************************;
	
	call matris_carp			; 1. Matris ve 2. Matris'i carp. Sonucu sonucmatris'e yaz.
	
	
	
	;******************************** SONUCU GOSTER ***********************************;
	
	call sonucmatris_goster		; sonucmatris'i ekranda goster
	
	mov dx, offset aciklamaMsj5
	call mesaj_goster
	call sayi_oku				; Program bitmeden once ENTER'a basilmasini bekle
	
	call exit_normal			; Programý normal olarak sonlandir. return 0
	
main endp


; MATRIS CARP
; Daha onceden icleri doldurulmus matris1 ve matris2 carpilir ve
; sonucu "sonucmatris" icine yuklenir
matris_carp proc
	
	push ax
	push bx
	push cx
	push dx
	
	mov cx, 0					; Matris kolon sayaci - x
	mov bx, 0					; Matris satir sayaci - y
	mov dx, 0					; Matris carpiminda kullaniliyor
	mov di, 0					; Matris dizisi indeksi icin
	mov si, 0					; Matris dizisi indeksi icin
	mov xdeger, 0				; Matris carpiminda kullaniliyor
	mov ydeger, 0				; Matris carpiminda kullaniliyor
	
	L1:							; Matris dongusu baslat
	
	mov ax, [matris2 + si]		; 1. ve 2. Matris elemanlari al
	mul [matris1 + di]			; ve carp
	push ax					; carpma sonucunu ax olarak stack'e sakla
	
	mov ax, bx					; Asagideki matematiksel islem icin bx gerekli
	mul mdegeri2				; (bx x mdegeri2 + xdeger) ile gerekli yere sonucu sakla
	mov dx, ax					; Yukardaki aritmetik ifadeyi gerceklestir
	add dx, xdeger				;    "        "         "        "
	add dx, dx					; word birimleri uzerinden islem yaptigimiz icin dx = 2 x dx
	pop ax						; Stack'de sakladigimiz ax'i geri yukle
	push di					; di stack'e sakla
	mov di, dx					; Matris uzerine erisimlerde di ve si kullanilabilir. 
	add [sonucMatris + di], ax	; Sonucmatris uzerine elde edilen carpimi topla
	pop di						; di stack'ten geri yukle
	add si, 2					; 2. matris indeksi 1 ilerlet. word = 2 byte
	
	inc xdeger					; xdeger, 2.matris kolon kontrolu
	mov ax, xdeger				;    "       "      "      "
	cmp ax, mdegeri2			;    "       "      "      "   
	jnz L1						; Xdeger, mdeger2 ye ulasana kadar donguye devam

	mov xdeger, 0				; xdeger sifirla
	inc ydeger					; ydeger 1 arttir
	mov ax, mdegeri2			; Uygun indeks hesaplamak icin carpma yap
	mul ydeger					; (++ydeger) x mdegeri2
	mov si, ax					; Sonucu "si" uzerine yukle
	
	add si, si					; si = si x 2
	add di, 2					; di = di + 2
	
	inc cx						; Kolon degiskenini bir ilerlet
	cmp cx, mdegeri				; Kolon sinir degerine ulasildi mi?
	jnz L1						; Kolon sinir degerine ulasilmadiysa devam et
	
	mov ydeger, 0				; ydeger sifirla
	mov si, 0					; si indeksi sifirla
	mov cx, 0					; Kolon degiskenini sifirla
	
	inc bx						; Satir degiskenini bir ilerlet
	cmp bx, ndegeri				; Satir sinir degerine ulasildi mi?
	jnz L1						; Satir sinir degerine ulasilmadiysa devam et
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
matris_carp endp


; Carpim sonucu olan Sonuc Matris'i matris seklinde ekranda gosterir.
sonucmatris_goster proc
	
	push ax
	push bx
	push cx
	push dx
	
	mov dx, offset enterMsj	
	call mesaj_goster			
	mov dx, offset sonucMsj
	call mesaj_goster
	
	mov cx, 0					; Matris kolon sayaci - x
	mov bx, 0					; Matris satir sayaci - y
	mov di, 0					; Matris dizisi indeksi icin
	
	L2:							; Matris1'i matris seklinde yazdirmak icin
	mov dx, offset enterMsj
	call mesaj_goster
	mov dx, offset acMsj		
	call mesaj_goster			
	
	L1:							; Matris dongusu baslat
	mov ax, [sonucMatris + di]	; Okunan sayiyi matris'te gerekli yere koy
	add di, 2					; matris1 word oldugu icin 2 byte ilerle
	
	mov sayi, ax				; Sayi ekrana yaz
	call sayi_yaz
	
	mov dx, offset virgulMsj	; Sayilar arasina virgul koy
	call mesaj_goster
	
	inc cx						; Kolon degiskenini bir ilerlet
	cmp cx, mdegeri2			; Kolon sinir degerine ulasildi mi?
	jnz L1						; Kolon sinir degerine ulasilmadiysa devam et
	
	mov cx, 0					; Kolon degiskenini sifirla

	mov dx, offset backMsj		; Fazla basilan virgul'u sil
	call mesaj_goster
	
	mov dx, offset kapaMsj		; Parantez kapat
	call mesaj_goster
	
	inc bx						; Satir degiskenini bir ilerlet
	cmp bx, ndegeri				; Satir sinir degerine ulasildi mi?
	jnz L2						; Satir sinir degerine ulasilmadiysa devam et
	
	mov dx, offset enterMsj	
	call mesaj_goster			
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
sonucmatris_goster endp


; Matris1 icerigini matris biciminde goster
matris_goster proc
	
	push ax
	push bx
	push cx
	push dx
	
	mov dx, offset enterMsj	
	call mesaj_goster			
	mov dx, offset matrisMsj2
	call mesaj_goster
	
	mov cx, 0					; Matris kolon sayaci - x
	mov bx, 0					; Matris satir sayaci - y
	mov di, 0					; Matris dizisi indeksi icin
	
	L2:							; Matris1'i matris seklinde yazdirmak icin
	mov dx, offset enterMsj
	call mesaj_goster
	mov dx, offset acMsj		
	call mesaj_goster			
	
	L1:							; Matris dongusu baslat
	mov ax, [matris1 + di]		; Okunan sayiyi matris'te gerekli yere koy
	add di, 2					; matris1 word oldugu icin 2 byte ilerle
	
	mov sayi, ax				; Sayi ekrana yaz
	call sayi_yaz
	
	mov dx, offset virgulMsj	; Sayilar arasina virgul koy
	call mesaj_goster
	
	inc cx						; Kolon degiskenini bir ilerlet
	cmp cx, mdegeri				; Kolon sinir degerine ulasildi mi?
	jnz L1						; Kolon sinir degerine ulasilmadiysa devam et
	
	mov cx, 0					; Kolon degiskenini sifirla

	mov dx, offset backMsj		; Fazla basilan virgul'u sil
	call mesaj_goster
	
	mov dx, offset kapaMsj		; Parantez kapat
	call mesaj_goster
	
	inc bx						; Satir degiskenini bir ilerlet
	cmp bx, ndegeri				; Satir sinir degerine ulasildi mi?
	jnz L2						; Satir sinir degerine ulasilmadiysa devam et
	
	mov dx, offset enterMsj	
	call mesaj_goster			
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
matris_goster endp


; Matris2 icerigini matris biciminde goster
matris_goster2 proc
	
	push ax
	push bx
	push cx
	push dx
	
	mov dx, offset enterMsj	
	call mesaj_goster			
	mov dx, offset matrisMsj4
	call mesaj_goster
	
	mov cx, 0					; Matris kolon sayaci - x
	mov bx, 0					; Matris satir sayaci - y
	mov di, 0					; Matris dizisi indeksi icin
	
	L2:							; Matris2'i matris seklinde yazdirmak icin
	mov dx, offset enterMsj
	call mesaj_goster
	mov dx, offset acMsj		
	call mesaj_goster			
	
	L1:							; Matris dongusu baslat
	mov ax, [matris2 + di]		; Okunan sayiyi matris'te gerekli yere koy
	add di, 2					; matris2 word oldugu icin 2 byte ilerle
	
	mov sayi, ax				; Sayi ekrana yaz
	call sayi_yaz
	
	mov dx, offset virgulMsj	; Sayilar arasina virgul koy
	call mesaj_goster
	
	inc cx						; Kolon degiskenini bir ilerlet
	cmp cx, mdegeri2			; Kolon sinir degerine ulasildi mi?
	jnz L1						; Kolon sinir degerine ulasilmadiysa devam et
	
	mov cx, 0					; Kolon degiskenini sifirla

	mov dx, offset backMsj		; Fazla basilan virgul'u sil
	call mesaj_goster
	
	mov dx, offset kapaMsj		; Parantez kapat
	call mesaj_goster
	
	inc bx						; Satir degiskenini bir ilerlet
	cmp bx, ndegeri2			; Satir sinir degerine ulasildi mi?
	jnz L2						; Satir sinir degerine ulasilmadiysa devam et
	
	mov dx, offset enterMsj	
	call mesaj_goster			
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
matris_goster2 endp


; 2. Matris icerigini doldur
matris_doldur2 proc
	
	push ax
	push bx
	push cx
	push dx
	
	mov cx, 0					; Matris kolon sayaci - x
	mov bx, 0					; Matris satir sayaci - y
	mov di, 0					; Matris dizisi indeksi icin
	
	L1:							; Matris dongusu baslat
	mov dx, offset enterMsj	; Gerekli mesajlari yaz
	call mesaj_goster			;   "       "        "
	mov dx, offset matrisMsj3	;   "       "        "
	call mesaj_goster			;   "       "        "
	mov dx, offset acMsj		;   "       "        "
	call mesaj_goster			;   "       "        "
	mov sayi, bx				;   "       "        "
	call sayi_yaz				;   "       "        "
	mov dx, offset virgulMsj	;   "       "        "
	call mesaj_goster			;   "       "        "
	mov sayi, cx				;   "       "        "
	call sayi_yaz				;   "       "        "
	mov dx, offset kapaMsj		;   "       "        "
	call mesaj_goster			;   "       "        "
	mov dx, offset girinizMsj	;   "       "        "
	call mesaj_goster			;   "       "        "
	
	call sayi_oku				; Kullanicidan mastris degeri iste
	mov ax, sayi				; Okunan sayiyi ax 'e yukle
	mov [matris2 + di], ax		; Okunan sayiyi matris'te gerekli yere koy
	add di, 2					; matris2 word oldugu icin 2 byte ilerle
	
	inc cx						; Kolon degiskenini bir ilerlet
	cmp cx, mdegeri2			; Kolon sinir degerine ulasildi mi?
	jnz L1						; Kolon sinir degerine ulasilmadiysa devam et
	
	mov cx, 0					; Kolon degiskenini sifirla 
	
	inc bx						; Satir degiskenini bir ilerlet
	cmp bx, ndegeri2			; Satir sinir degerine ulasildi mi?
	jnz L1						; Satir sinir degerine ulasilmadiysa devam et
	
	mov dx, offset enterMsj	; Gerekli mesajlari yaz
	call mesaj_goster			;   "       "        "
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
matris_doldur2 endp


; 1. Matris icerigini doldur
matris_doldur proc
	
	push ax
	push bx
	push cx
	push dx
	
	mov cx, 0					; Matris kolon sayaci - x
	mov bx, 0					; Matris satir sayaci - y
	mov di, 0					; Matris dizisi indeksi icin
	
	L1:							; Matris dongusu baslat
	mov dx, offset enterMsj	; Gerekli mesajlari yaz
	call mesaj_goster			;   "       "        "
	mov dx, offset matrisMsj	;   "       "        "
	call mesaj_goster			;   "       "        "
	mov dx, offset acMsj		;   "       "        "
	call mesaj_goster			;   "       "        "
	mov sayi, bx				;   "       "        "
	call sayi_yaz				;   "       "        "
	mov dx, offset virgulMsj	;   "       "        "
	call mesaj_goster			;   "       "        "
	mov sayi, cx				;   "       "        "
	call sayi_yaz				;   "       "        "
	mov dx, offset kapaMsj		;   "       "        "
	call mesaj_goster			;   "       "        "
	mov dx, offset girinizMsj	;   "       "        "
	call mesaj_goster			;   "       "        "
	
	call sayi_oku				; Kullanicidan mastris degeri iste
	mov ax, sayi				; Okunan sayiyi ax 'e yukle
	mov [matris1 + di], ax		; Okunan sayiyi matris'te gerekli yere koy
	add di, 2					; matris1 word oldugu icin 2 byte ilerle
	
	inc cx						; Kolon degiskenini bir ilerlet
	cmp cx, mdegeri				; Kolon sinir degerine ulasildi mi?
	jnz L1						; Kolon sinir degerine ulasilmadiysa devam et
	
	mov cx, 0					; Kolon degiskenini sifirla 
	
	inc bx						; Satir degiskenini bir ilerlet
	cmp bx, ndegeri				; Satir sinir degerine ulasildi mi?
	jnz L1						; Satir sinir degerine ulasilmadiysa devam et
	
	mov dx, offset enterMsj	; Gerekli mesajlari yaz
	call mesaj_goster			;   "       "        "
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
matris_doldur endp



; Binary -> ASCII cevirir ve ekrana yaz.
; Basamaklarý dongu kullanmadan hesapliyor
; ve ekrana yaziyor. Sayi negatif'se basina "-" yaziyor.
; Ekrana yazilcak sayi once "sayi" degiskenine aktarilmalidir.
; procedure bittiginde, "sayi" degiskeni degeri degisebilir.
sayi_yaz proc
	
	push ax
	push bx
	push cx
	push dx
	
	mov ax, sayi		; Sayi negatif mi?
	mov cl, 15			; 15 bit saga kaydirilir
	shr ax, cl			; sona kalan bit 1 ise, 
	cmp ax, 1			; sayi negatif demektir.
	je EKSI_YAZ
	
	mov ah, 2			; Orantilama icin		
	mov dl, ' '			; ekrana 1 bosluk koy
	int 21h
	
	jmp BASLA
	
	EKSI_YAZ:			; Sayi negatif, basina "-" yaz
	mov ah, 2		
	mov dl, '-'
	int 21h

	neg sayi			; Sayinin negatifini al
	
	BASLA:				; 16 bitlik en buyuk sayi 65535
						; O yuzden 5 basamagi tek tek ASCII cevrilcek
	
	; 5. BASAMAK CEVIR
	mov ax, sayi
	mov dx, 0			
	mov bx, 10000		; 10000'e bol
	div bx
	mov dx, ax 		; Sonucu dx'e koy
	push dx			; dx sakla
	add dl, 48			; ASCII cevir
	mov ah, 2			; Ekrana yaz
	int 21h
	
	mov ax, 10000		; Yazilan basamagin onluk degeri 
	pop dx				; orjinal "sayi"'dan cikarilmali
	mul dx
	sub sayi, ax		; Sayi'dan gerekli deger cikariliyor
	
	; 4. BASAMAK CEVIR				
	; 4. basamak icin yukardaki islemleri tekrarla
	mov ax, sayi
	mov dx, 0
	mov bx, 1000
	div bx
	mov dx, ax
	push dx
	add dl, 48
	mov ah, 2
	int 21h
	
	mov ax, 1000
	pop dx
	mul dx
	sub sayi, ax
	
	; 3. BASAMAK CEVIR				
	; 3. basamak icin yukardaki islemleri tekrarla
	mov ax, sayi
	mov dx, 0
	mov bx, 100
	div bx
	mov dx, ax
	push dx
	add dl, 48
	mov ah, 2
	int 21h
	
	mov ax, 100
	pop dx
	mul dx
	sub sayi, ax
	
	; 2. BASAMAK CEVIR				
	; 2. basamak icin yukardaki islemleri tekrarla
	mov ax, sayi
	mov dx, 0
	mov bx, 10
	div bx
	mov dx, ax 
	push dx
	add dl, 48
	mov ah, 2
	int 21h
	
	mov ax, 10
	pop dx
	mul dx
	sub sayi, ax
	
	; 1. BASAMAK CEVIR				
	; 1. basamak icin yukardaki islemleri tekrarla
	mov ax, sayi 
	mov dx, 0
	mov bx, 1
	div bx
	mov dx, ax 
	add dl, 48
	mov ah, 2
	int 21h
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret

sayi_yaz endp


; ENTER'a basilana kadar girilen sayiyi okur
; ve binary formatina donusturur.
; Okunan sayi "sayi" degiskeni ile dondurulur
sayi_oku proc

	push ax				
	push bx
	push cx
	push dx
	
	mov sayi, 0				; sayi'yi resetle
	
	OKU:					; enter'a basilana kadar oku
	mov ah, 1
	int 21h
	mov buffer, al
	cmp buffer, 0dh			; enter'a basildi mi?
	jz CIK					; okumayi sonlandir
	
	;cmp buffer, 8h			; backspace'e basildiysa yoksay!
	;jz	OKU
	
	cmp buffer, '-'			; eksi bir deger mi girildi?
	jnz NEG_DEGIL					
	
	mov negatif, 1			; sayi negatif, negatif anahtari setle
	jmp OKU					; - isareti okundu, okumaya devam

	NEG_DEGIL:
	
	mov ax, 10				; sabitA'yi  
	mul sayi				; 10 ile carp
	mov sayi, ax
	sub buffer, 48			; ASCII'den integer'a dondur
	xor ax, ax				; move ax, 0  
	mov al, buffer
	add sayi, ax			; sabitA = sabitA + buffer
	
	jmp OKU					; sayi okumaya devam
	
	CIK:					; sayi okuma bitti
	
	cmp negatif, 0			; sayi negatif miydi?
	jz NEG_DEGIL2

	neg sayi				; sayi negatifse, eksi yap

	NEG_DEGIL2:
	
	mov negatif, 0			; negatif anahtarini resetle
	
	pop dx
	pop cx
	pop bx
	pop ax
	ret

sayi_oku endp


; Programdan normal cik
exit_normal proc

	mov ax, 4c00h	; Exit code 0
	int 21h

exit_normal endp


; $ ile sonlandirilmis string ekrana yazar
; yazilcak olan string'in offseti dx'e konmalidir.
mesaj_goster proc

	mov ah, 9h
	int 21h
	ret
	
mesaj_goster endp


end main
