;=============================================================================
; pht_refl_lunar
;
;=============================================================================
function pht_refl_lunar, mu, mu0, parm
 return, mu0/(mu + mu0)
end
;=============================================================================
