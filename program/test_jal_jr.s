.text
# Pour les tests ne pas utiliser le registre $1

jal etiquette
lui $28, 0x0001

etiquette:
lui $28, 0x0002
jr $31

# pout_start
# 00020000
# 00010000
# pout_end
