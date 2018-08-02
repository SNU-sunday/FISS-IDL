pro fiss_lines,  band,  elms, wvs, ews

case strmid(band,0,4) of
'6562' : begin
            wvs=[58.149,  58.65,   59.5880,  59.813,  60.555,  60.68,  61.097]

            ews=[             7.,       1.5,              14.,                 3.,                 10.,            12.,               5]
            elms=['H2O',       'H2O ',          'Ti II',                  ' ',              'H2O',       'Si I',          'H2O']
            ref=['utrecht',  'utrecht',      'VALD',       'utrecht',     'utrecht',  'NSRD',     'utrecht']
            wvs=[wvs,    62.817,  63.521,  64.061,  64.206,    65.545,  65.90,  66.55]+6500.d0
            ews=[ews,          4020,             4.5,     4.5,            14.,               3.,                 1.,            3.]
            elms=[elms,         'H I',        'H2O',      'H2O',        'H2O',           'H2O',         'V I',        '' ]
           ref=[ref,         'NSRD', 'utrecht',     'utrecht',   'utrecht',     'utrecht',    'utrecht',  'utrecht']
             end
'8542': begin
            wvs=               [36.165,  36.45, 36.68,  38.0152,  38.25,  39.888, 40.817,  42.089,   46.222]+8500.D0
            ews=                 [58.,        3.,        3.,         31.,        2.,          3.5,        8.,           3670.,   5. ]
            elms=                ['Si I',      '' ,        '',         'Fe I',     'CN',      'H2O',    'H2O',     'Ca II', 'H2O']
            ref=                 ['NIST',  'utrecht',  ' ',   'NAVE', 'utrecht',    'utecht', 'NSRD', 'utrecht']
            end
else    : begin
            end
endcase

end