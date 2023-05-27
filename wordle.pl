play:- write('Welcome to Pro-Wordle!\n----------------------\n').

build_kb:- write('Please enter a word and its category on separate lines:'),nl,
            read(A),
			( 
			(A=done,write('Done building the words database...'))
			; 
			(read(B), assert(word(A,B)),build_kb)
			).
			
main:- play, 
       build_kb,nl,
	   wordle.
	   
is_category(C):- word(_,C).

is_word(C):- word(C,_).

categories(L):- setof(C,is_category(C),L).

words(L):- setof(C,is_word(C),L).

available_length(X):- words(L),
                      checklength(L,X).

wordsincat(C,L):- setof(W,word(W,C),L).



checklength([H|_],X):- atom_length(H,X).

checklength([_|T],X):- checklength(T,X).

available_lengths(L):- setof(X,available_length(X),L).

pick_word(W,L,C):- word(W,C),
                   atom_length(W,L).


correct_letters(L1,L2,CL):- intersection(L1,L2,CL).

correct_positions(L1,L2,PL):- correct_positionsh(L1,L2,[],PL).

correct_positionsh([],[],Acc,Acc).

correct_positionsh([H1|T1],[H2|T2],Acc,PL):-H1=H2, 
                                            append(Acc,[H1],NAcc),
											correct_positionsh(T1,T2,NAcc,PL).
											
correct_positionsh([H1|T1],[H2|T2],Acc,PL):-H1\=H2,
                                            correct_positionsh(T1,T2,Acc,PL).

avlen(C,L):- setof(W,word(W,C),L1),
             avlen(C,L1,[],L).
			 
avlen(_,[],Acc,Acc).

avlen(C,[H|T],Acc,L):-atom_length(H,X),
                      append(Acc,[X], NAcc),
					  avlen(C,T,NAcc,L).

chooseCat(C):- write('Choose a category: '),nl,read(A),
               ((is_category(A),C=A)
			   ;
			   (\+is_category(A),write('This category does not exist.'),nl,chooseCat(C))).

chooseLen(C,L):- write('Choose a length:'),nl,read(Ln),
                (
				(avlen(C,L1),member(Ln,L1),L=Ln)
				;
				(avlen(C,L1),\+member(Ln,L1),write('There are no words of this length.'),nl,chooseLen(C,L))
				).
		
wordle:-write('The available categories are:'), categories(L),write(L),nl,
        chooseCat(C),
		chooseLen(C,Ln), X is Ln+1,
		write('Game Started. You have '), write(X), write(' guesses.'),nl, wordle2(Ln,X,C).
		
wordle2(Ln,X,C):- (
                  (X=<0,nl,write('You Lost'),!)
				  ;
				  (X>0,
				  write('Enter a word composed of '), write(Ln),write(' letters.'),nl,
				  read(WORD),atom_length(WORD,Y),
				  (
				  (Y\=Ln,
				  write('Word is not composed of '),write(Ln),write(' letters.Try again.'),nl,
				  write('Remaining guesses are '),write(X),nl,wordle2(Ln,X,C))
				  ;
				  (Y==Ln,words(S),
				  (\+member(WORD,S), write('Invalid word. Try again'),nl,write('Remaning guesses are '),write(X),nl,wordle2(Ln,X,C))
				  ;
				  (member(WORD,S),pick_word(H,Ln,C),atom_chars(WORD,W1),atom_chars(H,H1),
				  correct_letters(W1,H1,CL),correct_positions(W1,H1,CP),length(CP,N2),
				  (
				  (Ln==N2,write('You Won!'),!)
				  ;
				  (
				  sort(CL,CL1),
				  write('Correct letters are: '),write(CL1),nl,
				  write('Correct letters in correct positions are: '),write(CP),nl,
				  write('Remaining guesses are '), X1 is X-1,write(X1),nl,wordle2(Ln,X1,C))
				  )
				  )
				  )
				  )
				  )
				  ).
        
