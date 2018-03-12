.text
# Pour les tests ne pas utiliser le registre $1

jal etiquette
lui $28, 0x0002
jr $2

etiquette:
lui $28, 0x0001
jalr $2, $31
lui $28, 0x0003

# pout_start
# 00010000
# 00020000
# 00030000
# pout_end
