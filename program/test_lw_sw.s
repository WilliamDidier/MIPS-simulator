.text
# Pour les tests ne pas utiliser le registre $1
# Ici on va tester LW et SW
addi $2, $0, 0x0001
sw $2, 0($0)
#On a mis la valeur 1 dans l'adresse 0 de la mémoire
lw $28, 0($0)
#On stocke la valeur précédemment chargée dans le registre de retour

#pout_start
#0x0001
#pout_end
