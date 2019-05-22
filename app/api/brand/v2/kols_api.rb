module Brand
  module V2
    class KolsAPI < Base
      group do
        before do
          authenticate!
        end

        resource :kols do

          desc 'pending tenders' #待合作
          params do
            requires :creation_id, type: Integer
          end
          get 'pending_tenders' do
            @creation = Creation.find params[:creation_id]
            @selected_kols = @creation.creation_selected_kols.by_status('pending')

            present @selected_kols, with: Entities::Kol
          end

          desc 'valid tenders' #合作中
          params do
            requires :creation_id, type: Integer
          end
          get 'cooperation_tenders' do
            @creation = Creation.find params[:creation_id]
            @selected_kols = @creation.creation_selected_kols.cooperation

            present @selected_kols, with: Entities::Kol
          end

          desc 'finished tender' #已完成
          params do
            requires :creation_id, type: Integer
          end
          get 'finished_tenders' do
            @creation = Creation.find params[:creation_id]
            @selected_kols = @creation.creation_selected_kols.by_status('finished')

            present @selected_kols, with: Entities::Kol
          end

          post 'search' do
            data = {
  "page_no": params[:page_no],
  "page_size": params[:page_size],
  "total_record_count": Kol.count,
  "actual_total_record_count": Kol.count,
  "total_page_count": (Kol.count/params[:page_size]).to_i + 1,
  "actual_total_page_count": (Kol.count/params[:page_size]).to_i + 1,
  "data": (Kol.offset(params[:page_no].to_i*params[:page_size].to_i).limit(params[:page_size].to_i).map {|kol|
                {
                  "profile_id": kol.facebook_link.to_s,
                  "profile_name": kol.name,
                  "avatar_url": "http://wx.qlogo.cn/mmhead/Q3auHgzwzM7cUK96eziam5YQskZWVzoEO4jcabCnsISj5FOr8QfNAew/132",
                  "weixin_id": "gh_c782d11518c5",
                  "description_raw": "",
                  "fans_number": 300000,
                  "r8_id": "MzUxMDAwNjIwMw==",
                  "score": 1.0,
                  "n_posts": 8,
                  "index_time": "2018-03-28T21:08:07",
                  "_influence": 1000.0,
                  "max_score": 1.0,
                  "correlation": 1.0,
                  "influence": 1.0,
                  "stats": {
                    "total_posts": 3,
                    "total_reads": 0,
                    "max_reads": 0,
                    "avg_reads": 0.0,
                    "total_likes": 0,
                    "max_likes": 0,
                    "avg_likes": 0.0,
                    "total_sum_engagement": 0,
                    "max_sum_engagement": 0,
                    "avg_sum_engagement": 0.0,
                    "total_post_influences": 0.0,
                    "max_post_influences": 0.0,
                    "avg_post_influences": 0.0,
                    "data_date": "2019-01-07",
                    "no_of_days": 21,
                    "avg_daily_posts": 0.14
                  },
                  "industries": [
                    {
                      "health": 1
                    },
                    {
                      "music": 1
                    },
                    {
                      "travel": 1
                    }
                  ],
                  "kol_id": nil,
                  "pricing": {
                    "direct_price": 8500.0,
                    "forward_price": 8500.0,
                    "allow_url": nil,
                    "can_have_link": nil,
                    "reservation_remark": nil,
                    "collaboration": nil,
                    "can_be_original": nil
                  }
                }
              }),
  "es_query_for_debug": {
    "track_scores": true,
    "_source": {
      "excludes": [
        "posts"
      ]
    },
    "sort": [
      {
        "influence.kol_influences": {
          "order": "desc"
        }
      },
      {
        "_score": {
          "order": "desc"
        }
      }
    ],
    "from": 0,
    "size": 10,
    "query": {
      "bool": {
        "should": [

        ],
        "must": [
          {
            "bool": {
              "should": [

              ]
            }
          },
          {
            "range": {
              "fans_number": {
                "gte": "100000"
              }
            }
          },
          {
            "terms": {
              "profile_id": [
                "1004454162",
                "1029262955",
                "1052308822",
                "1054096047",
                "1060603161",
                "1062383455",
                "1063687330",
                "1080410951",
                "1085359724",
                "1106957832",
                "1135987804",
                "1139204272",
                "1154814715",
                "1159768381",
                "1164589025",
                "1170535403",
                "1188399215",
                "1191050205",
                "1191258655",
                "1191965271",
                "1193525177",
                "1193725273",
                "1198183614",
                "1199769167",
                "1212642787",
                "1215087445",
                "1215914717",
                "1216098513",
                "1218346612",
                "1218639357",
                "1219310523",
                "1220089451",
                "1220740480",
                "1220824437",
                "1221485670",
                "1225512093",
                "1226826712",
                "1230077777",
                "1231252240",
                "1234772200",
                "1235329061",
                "1240375710",
                "1244767010",
                "1245360814",
                "1247915174",
                "1248351970",
                "1249137735",
                "1251372271",
                "1253268747",
                "1254485312",
                "1255965235",
                "1256645862",
                "1258009312",
                "1263303955",
                "1264775587",
                "1265061803",
                "1265122813",
                "1265998927",
                "1267454277",
                "1268257027",
                "1268518877",
                "1270869704",
                "1271017671",
                "1272519815",
                "1273461107",
                "1275017594",
                "1286891293",
                "1290025393",
                "1290519354",
                "1294355705",
                "1295770221",
                "1296119181",
                "1301913240",
                "1305972435",
                "1307907720",
                "1312429562",
                "1313697151",
                "1314608344",
                "1323527941",
                "1326937777",
                "1338216910",
                "1344360230",
                "1351358727",
                "1357622317",
                "1364268573",
                "1370640741",
                "1371117067",
                "1371731565",
                "1390113780",
                "1393100891",
                "1395394490",
                "1395415114",
                "1397634191",
                "1398025082",
                "1398027593",
                "1400359365",
                "1400776392",
                "1424753330",
                "1433942014",
                "1434387020",
                "1439414042",
                "1440103481",
                "1482425570",
                "1496813671",
                "1496814565",
                "1497009881",
                "1497087080",
                "1497252243",
                "1498124904",
                "1510087120",
                "1510402622",
                "1516525515",
                "1516526131",
                "1524748171",
                "1526118322",
                "1549362863",
                "1557303822",
                "1559383255",
                "1559696543",
                "1570983251",
                "1571801883",
                "1571835713",
                "1573953470",
                "1575555751",
                "1577794853",
                "1580993472",
                "1582734423",
                "1586480135",
                "1593833437",
                "1594611432",
                "1596409212",
                "1596931083",
                "1599441204",
                "1607812347",
                "1609550015",
                "1610356014",
                "1611853174",
                "1614747181",
                "1615743184",
                "1615813834",
                "1617902267",
                "1619766521",
                "1619899087",
                "1622448670",
                "1622943065",
                "1625152340",
                "1627825392",
                "1628073650",
                "1628669597",
                "1629072852",
                "1629461787",
                "1630749901",
                "1634058407",
                "1635726043",
                "1639498782",
                "1640376730",
                "1640456497",
                "1640699454",
                "1641492212",
                "1641532820",
                "1641561812",
                "1642471052",
                "1642482194",
                "1642492851",
                "1642493805",
                "1642512402",
                "1642625033",
                "1644114654",
                "1644395354",
                "1644489953",
                "1644739504",
                "1644948230",
                "1645225852",
                "1645773865",
                "1645817972",
                "1646051850",
                "1646068663",
                "1646343160",
                "1649173367",
                "1649240381",
                "1649469483",
                "1649853601",
                "1649873781",
                "1650438774",
                "1650440411",
                "1650440897",
                "1650443902",
                "1650923121",
                "1651428902",
                "1651700972",
                "1652194081",
                "1652484947",
                "1652527364",
                "1653202503",
                "1653400800",
                "1653426154",
                "1653460650",
                "1653603955",
                "1653689003",
                "1653957693",
                "1654140974",
                "1654159825",
                "1654208041",
                "1654691947",
                "1654815470",
                "1655852940",
                "1656384667",
                "1656737654",
                "1656818114",
                "1656831930",
                "1658402750",
                "1658444254",
                "1658500170",
                "1660452532",
                "1660612723",
                "1660816123",
                "1660933072",
                "1660943022",
                "1661200593",
                "1661347232",
                "1661377270",
                "1661413882",
                "1661504722",
                "1661558660",
                "1661598840",
                "1661681614",
                "1661682580",
                "1662546043",
                "1663932242",
                "1664798221",
                "1665164045",
                "1667983181",
                "1668368147",
                "1669817922",
                "1670032377",
                "1670311151",
                "1670879140",
                "1671569733",
                "1672143605",
                "1676001761",
                "1676976974",
                "1677875323",
                "1678013442",
                "1678319587",
                "1679272984",
                "1679302152",
                "1681029540",
                "1681160103",
                "1681489322",
                "1681971781",
                "1682207150",
                "1682650430",
                "1682868903",
                "1683796441",
                "1685715705",
                "1686001015",
                "1687339164",
                "1687445053",
                "1688864597",
                "1689423542",
                "1689974542",
                "1689980344",
                "1691703935",
                "1692902542",
                "1697601814",
                "1699258907",
                "1699540307",
                "1700648435",
                "1700720163",
                "1703371307",
                "1704322775",
                "1704390923",
                "1704442730",
                "1704819467",
                "1706500860",
                "1707427294",
                "1707859752",
                "1707933832",
                "1708922835",
                "1712356403",
                "1712831753",
                "1713926427",
                "1715196611",
                "1716577367",
                "1717833412",
                "1718442907",
                "1718493627",
                "1719190750",
                "1720962692",
                "1722555060",
                "1723309721",
                "1725725780",
                "1726276573",
                "1726406904",
                "1726735172",
                "1727191592",
                "1729653661",
                "1730599295",
                "1730795801",
                "1731230547",
                "1732235143",
                "1732480923",
                "1734479835",
                "1734530730",
                "1735937570",
                "1735989994",
                "1736236341",
                "1736693382",
                "1738006505",
                "1739038340",
                "1740006601",
                "1740492340",
                "1742013781",
                "1742884561",
                "1743849527",
                "1743880721",
                "1744042262",
                "1744762545",
                "1745461094",
                "1745885344",
                "1746313972",
                "1746575865",
                "1747495983",
                "1747498221",
                "1747779291",
                "1748440125",
                "1749220481",
                "1749224837",
                "1749990115",
                "1750270991",
                "1752021340",
                "1752549400",
                "1752673095",
                "1752740784",
                "1753013331",
                "1756505647",
                "1756807885",
                "1757220135",
                "1757381295",
                "1757476803",
                "1757599201",
                "1757600001",
                "1758242183",
                "1758476561",
                "1758895582",
                "1760566541",
                "1760607222",
                "1762640091",
                "1763405902",
                "1764222885",
                "1764855964",
                "1764971600",
                "1765812654",
                "1765813640",
                "1767702282",
                "1767910704",
                "1769293417",
                "1769333595",
                "1769397680",
                "1769558285",
                "1769771933",
                "1769811365",
                "1770623052",
                "1770840225",
                "1771753264",
                "1771806172",
                "1772950572",
                "1773341862",
                "1774006332",
                "1774041753",
                "1774281917",
                "1774860981",
                "1775941687",
                "1776648211",
                "1779884443",
                "1780360622",
                "1780449083",
                "1780759813",
                "1782599645",
                "1782818567",
                "1783199611",
                "1783493742",
                "1783561583",
                "1783681865",
                "1784231227",
                "1784278954",
                "1784742491",
                "1784830527",
                "1784839414",
                "1784894794",
                "1785833173",
                "1786713865",
                "1787738984",
                "1789520024",
                "1790036227",
                "1790042191",
                "1791155847",
                "1791330464",
                "1792010363",
                "1794088817",
                "1794263067",
                "1794265235",
                "1794993692",
                "1795139330",
                "1795219824",
                "1795373135",
                "1795489985",
                "1795509335",
                "1795593274",
                "1795617563",
                "1796411280",
                "1797484712",
                "1798413817",
                "1800341434",
                "1801597364",
                "1802025651",
                "1803278217",
                "1803613277",
                "1804565432",
                "1805406782",
                "1806910981",
                "1807384352",
                "1809457954",
                "1810248254",
                "1813378072",
                "1814392721",
                "1814699320",
                "1816041162",
                "1816508841",
                "1818371444",
                "1819208550",
                "1819437687",
                "1819746910",
                "1821555443",
                "1822155333",
                "1823608784",
                "1827639844",
                "1829417413",
                "1829984955",
                "1831423573",
                "1832447572",
                "1833134491",
                "1834641361",
                "1837074624",
                "1838362872",
                "1838886692",
                "1839588863",
                "1840208253",
                "1843872915",
                "1846580741",
                "1849181240",
                "1849247560",
                "1849367094",
                "1850235592",
                "1850540183",
                "1851524785",
                "1852220282",
                "1852405495",
                "1852518015",
                "1853073072",
                "1853112251",
                "1854333263",
                "1857414070",
                "1857688322",
                "1860389332",
                "1861274124",
                "1863822692",
                "1864295150",
                "1866833821",
                "1868656825",
                "1871110130",
                "1871721375",
                "1874120122",
                "1874783071",
                "1877951477",
                "1877965042",
                "1879778060",
                "1880396074",
                "1881182867",
                "1883792537",
                "1883797443",
                "1885003720",
                "1885454921",
                "1886252463",
                "1887259304",
                "1887790981",
                "1887826884",
                "1887831331",
                "1887863544",
                "1888450717",
                "1889087845",
                "1889158243",
                "1889481010",
                "1890124614",
                "1891208760",
                "1893377101",
                "1893752581",
                "1893769523",
                "1894586762",
                "1895289983",
                "1895327843",
                "1895520105",
                "1896481783",
                "1896648781",
                "1899541720",
                "1900049715",
                "1900418064",
                "1900739437",
                "1901060075",
                "1901149905",
                "1901445055",
                "1909253791",
                "1909650185",
                "1909751124",
                "1910678435",
                "1912222221",
                "1912713353",
                "1915389755",
                "1916805220",
                "1919114090",
                "1920024743",
                "1920047787",
                "1921208427",
                "1925950032",
                "1926105135",
                "1926909715",
                "1927536681",
                "1927740905",
                "1930072831",
                "1930513552",
                "1932345525",
                "1936713014",
                "1939419914",
                "1939766834",
                "1940659935",
                "1941349302",
                "1942859227",
                "1944603171",
                "1947792782",
                "1950158872",
                "1954559412",
                "1956700750",
                "1956911795",
                "1959182407",
                "1960785875",
                "1961381224",
                "1962117985",
                "1962190703",
                "1964688815",
                "1964744762",
                "1964933187",
                "1969331274",
                "1971890324",
                "1974152033",
                "1974576991",
                "1975753537",
                "1976160811",
                "1976402261",
                "1980465571",
                "1982163497",
                "1984738451",
                "1986481745",
                "1989042943",
                "1990387410",
                "1992523932",
                "1995839643",
                "1999265897",
                "2002276175",
                "2004995700",
                "2005127421",
                "2011075080",
                "2011796120",
                "2011939377",
                "2014149464",
                "2018514850",
                "2023833992",
                "2025262257",
                "2025534657",
                "2025994775",
                "2032139271",
                "2032813647",
                "2034347300",
                "2036401884",
                "2046840541",
                "2047893792",
                "2049371122",
                "2050260197",
                "2053148147",
                "2053398617",
                "2056382103",
                "2073306841",
                "2075927063",
                "2081420765",
                "2084348103",
                "2089410433",
                "2090591961",
                "2093047690",
                "2093778914",
                "2094192812",
                "2095326403",
                "2099153431",
                "2102189371",
                "2105564885",
                "2107493602",
                "2115176080",
                "2116386001",
                "2117706524",
                "2118746300",
                "2119367023",
                "2121866391",
                "2123664205",
                "2125224720",
                "2126471765",
                "2130272020",
                "2134374414",
                "2136099480",
                "2138696605",
                "2139876143",
                "2140227493",
                "2140521137",
                "2141064523",
                "2141791335",
                "2141853335",
                "2142168143",
                "2144576481",
                "2146540060",
                "2146965345",
                "2149069737",
                "2149964255",
                "2150182731",
                "2151768482",
                "2153117015",
                "2153773471",
                "2154105251",
                "2154212385",
                "2154946027",
                "2155138921",
                "2155159645",
                "2156466452",
                "2172631523",
                "2173998637",
                "2176438597",
                "2185104815",
                "2188113935",
                "2189608911",
                "2191302165",
                "2192328045",
                "2201531190",
                "2203873523",
                "2210869832",
                "2211400920",
                "2212904834",
                "2212928457",
                "2213488924",
                "2217389255",
                "2219227283",
                "2238563471",
                "2239529624",
                "2242389770",
                "2243807243",
                "2245075615",
                "2247252503",
                "2248914032",
                "2249909614",
                "2250601672",
                "2257685451",
                "2259906485",
                "2275231151",
                "2278809187",
                "2280719873",
                "2284668911",
                "2286908003",
                "2288652234",
                "2292048583",
                "2292120434",
                "2293461871",
                "2294966241",
                "2296748155",
                "2297493511",
                "2301726604",
                "2311077472",
                "2312152482",
                "2313500494",
                "2327860492",
                "2330077697",
                "2331517654",
                "2339964450",
                "2343621275",
                "2347781093",
                "2354160970",
                "2354939132",
                "2368150120",
                "2368304713",
                "2368736730",
                "2368746162",
                "2369592070",
                "2370071734",
                "2370784220",
                "2373286762",
                "2373525683",
                "2376776641",
                "2385010470",
                "2385360871",
                "2389641745",
                "2394069222",
                "2396658275",
                "2396815443",
                "2408286121",
                "2411750412",
                "2413716950",
                "2414490394",
                "2427279700",
                "2427299460",
                "2431578944",
                "2447680824",
                "2457925782",
                "2471336433",
                "2474528550",
                "2475967382",
                "2476481021",
                "2478838621",
                "2479684881",
                "2481265575",
                "2484570551",
                "2485283694",
                "2485565120",
                "2488492271",
                "2489923091",
                "2495327692",
                "2495407521",
                "2496070130",
                "2496389047",
                "2497449104",
                "2499740747",
                "2504355894",
                "2505894464",
                "2509958092",
                "2514475045",
                "2518317185",
                "2518349655",
                "2519069512",
                "2522452950",
                "2529898962",
                "2535005327",
                "2548864682",
                "2550491047",
                "2552721372",
                "2562478665",
                "2562658331",
                "2564668917",
                "2574126482",
                "2590739307",
                "2594632914",
                "2609935572",
                "2610898374",
                "2611585414",
                "2615632951",
                "2619981000",
                "2624215580",
                "2625481001",
                "2626682903",
                "2630422743",
                "2637129912",
                "2640113513",
                "2642168821",
                "2643849691",
                "2645319702",
                "2647822870",
                "2651328751",
                "2655485361",
                "2656829134",
                "2667483043",
                "2670125917",
                "2673619603",
                "2679503381",
                "2683912785",
                "2685402452",
                "2697416452",
                "2700771337",
                "2700823363",
                "2700835853",
                "2707150923",
                "2709577332",
                "2713019943",
                "2718351604",
                "2720197361",
                "2723065734",
                "2742964807",
                "2749699323",
                "2757639945",
                "2759386641",
                "2760733525",
                "2765721850",
                "2769458511",
                "2771074184",
                "2780201277",
                "2785011341",
                "2785093493",
                "2785125355",
                "2803301701",
                "2804610542",
                "2807684421",
                "2807837367",
                "2810445594",
                "2813469294",
                "2814680487",
                "2817145687",
                "2818268052",
                "2819165581",
                "2822771827",
                "2824626113",
                "2830048180",
                "2838161652",
                "2839474890",
                "2839943455",
                "2840252665",
                "2841054630",
                "2853016445",
                "2854307262",
                "2855071827",
                "2856101490",
                "2859452070",
                "2865341160",
                "2868676035",
                "2878439511",
                "2881589927",
                "2881649203",
                "2882040313",
                "2893052643",
                "2903242842",
                "2903242882",
                "2903271200",
                "2903298060",
                "2906814961",
                "2914273942",
                "2914644812",
                "2921223134",
                "2921244020",
                "2936882141",
                "2939662322",
                "2944835493",
                "2945769887",
                "2949327571",
                "2953305612",
                "2962345755",
                "2970036311",
                "2976376993",
                "2984246397",
                "2989447800",
                "3027752797",
                "3035027362",
                "3035060372",
                "3035060384",
                "3035076144",
                "3042094223",
                "3042495472",
                "3057614631",
                "3082731712",
                "3089496442",
                "3089566712",
                "3089575562",
                "3090409010",
                "3095233225",
                "3096157670",
                "3099016097",
                "3125274753",
                "3132811615",
                "3132815245",
                "3157993353",
                "3158902295",
                "3167104922",
                "3171562511",
                "3191534861",
                "3197993670",
                "3200906487",
                "3202856841",
                "3209782551",
                "3212157750",
                "3215352515",
                "3217154095",
                "3218586493",
                "3226750090",
                "3227981372",
                "3228016330",
                "3229251653",
                "3236026814",
                "3238094084",
                "3244028160",
                "3245033672",
                "3248206144",
                "3249327460",
                "3250316641",
                "3282913214",
                "3295758791",
                "3305466197",
                "3306279953",
                "3313110484",
                "3316144700",
                "3329094262",
                "333916400",
                "3341042102",
                "3348777784",
                "3360031512",
                "3402314844",
                "3450359070",
                "3494286921",
                "3509370327",
                "3560605004",
                "3564178011",
                "3613440743",
                "3618163381",
                "3693578863",
                "3709863133",
                "3711753553",
                "3721917331",
                "3737404712",
                "3738294507",
                "3738542414",
                "3738542557",
                "3781929917",
                "3825044959",
                "3833070073",
                "3847782259",
                "3851373536",
                "3865331884",
                "3891512829",
                "3901624042",
                "3920497465",
                "3920631851",
                "3929923929",
                "3943178392",
                "3964641760",
                "5039775130",
                "5044281310",
                "5059204075",
                "5075056335",
                "5076468377",
                "5076516542",
                "5085307294",
                "5088727174",
                "5088862652",
                "5101863971",
                "5107595110",
                "5124766260",
                "5126427168",
                "5135616559",
                "5144481626",
                "5162765902",
                "5181464632",
                "5222913979",
                "5225999165",
                "5235744929",
                "5267970860",
                "5294919465",
                "5379707231",
                "5389720333",
                "5397821743",
                "5451021485",
                "5464919306",
                "5466592990",
                "5478684865",
                "5480534464",
                "5483008422",
                "5487426270",
                "5489171304",
                "5507878378",
                "5512922997",
                "5540466595",
                "5582337946",
                "5586771466",
                "5596017363",
                "5596974100",
                "5621389511",
                "5626139459",
                "5662576957",
                "5685568105",
                "5696270328",
                "5699464819",
                "5704834946",
                "5745465714",
                "5745465807",
                "5745465811",
                "5773745644",
                "5910321076",
                "5938023508",
                "6265626648",
                "6315393589",
                "6504071430",
                "6514389491",
                "6552600645"
              ]
            }
          }
        ],
        "must_not": [

        ]
      }
    }
  }
}

            data2 = {
              "page_no": 0,
              "page_size": 10,
              "total_record_count": 3112,
              "total_page_count": 312,
              "data": (Kol.offset(params[:page_no].to_i*params[:page_size].to_i).limit(params[:page_size].to_i).map {|kol|
                {
                  "profile_id": "MzUxMDAwNjIwMw==",
                  "profile_name": "常飞飞",
                  "avatar_url": "http://wx.qlogo.cn/mmhead/Q3auHgzwzM7cUK96eziam5YQskZWVzoEO4jcabCnsISj5FOr8QfNAew/132",
                  "weixin_id": "gh_c782d11518c5",
                  "description_raw": "",
                  "fans_number": 300000,
                  "r8_id": "MzUxMDAwNjIwMw==",
                  "score": 1.0,
                  "n_posts": 8,
                  "index_time": "2018-03-28T21:08:07",
                  "_influence": 1000.0,
                  "max_score": 1.0,
                  "correlation": 1.0,
                  "influence": 1.0,
                  "stats": {
                    "total_posts": 3,
                    "total_reads": 0,
                    "max_reads": 0,
                    "avg_reads": 0.0,
                    "total_likes": 0,
                    "max_likes": 0,
                    "avg_likes": 0.0,
                    "total_sum_engagement": 0,
                    "max_sum_engagement": 0,
                    "avg_sum_engagement": 0.0,
                    "total_post_influences": 0.0,
                    "max_post_influences": 0.0,
                    "avg_post_influences": 0.0,
                    "data_date": "2019-01-07",
                    "no_of_days": 21,
                    "avg_daily_posts": 0.14
                  },
                  "industries": [
                    {
                      "health": 1
                    },
                    {
                      "music": 1
                    },
                    {
                      "travel": 1
                    }
                  ],
                  "kol_id": nil,
                  "pricing": {
                    "direct_price": 8500.0,
                    "forward_price": 8500.0,
                    "allow_url": nil,
                    "can_have_link": nil,
                    "reservation_remark": nil,
                    "collaboration": nil,
                    "can_be_original": nil
                  }
                }
              })
            }
            return data
          end
        end
      end
    end
  end
end