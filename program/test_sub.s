.text
# Pour les tests ne pas utiliser le registre $1

lui $2, 0x0001
lui $3, 0x0002

sub $28, $3, $2

# pout_start
# 00010000
# pout_end
