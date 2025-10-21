package edu.sm.app.service;

import edu.sm.app.dto.StyleAnalysisResult;
import edu.sm.app.dto.StyleRecommendation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
public class StyleRecommendService {

    public StyleRecommendation recommend(StyleAnalysisResult a) {
        StyleRecommendation rec = new StyleRecommendation();

        List<String> rules = List.of(
                "톤에 맞는 팔레트에서 색을 선택하세요.",
                a.getContrast().equalsIgnoreCase("low") ? "상/하의 명도 차이를 크게 두지 마세요." : "포인트 대비를 살짝 주어도 좋습니다.",
                a.getTone().contains("summer") ? "차가운 파스텔/낮은 채도를 우선 추천합니다." : "따뜻한/선명한 색을 우선 고려합니다."
        );
        rec.setRules(rules);

        // 간단 샘플 아이템
        rec.setTops(List.of(
                item("T101","soft boatneck tee","top",pick(a,0),"relaxed","boatneck","low 대비/쿨톤에 적합"),
                item("T102","linen open collar","top",pick(a,1),"relaxed","open","톤 팔레트와 조화")
        ));
        rec.setBottoms(List.of(
                item("B201","tapered slacks","bottom","#EFEFEF","regular",null,"무난한 실루엣으로 상의 강조")
        ));
        rec.setOuter(List.of(
                item("O301","light cardigan","outer",pick(a,2),"regular",null,"톤과 명도 맞춤")
        ));
        rec.setOnepiece(List.of(
                item("D401","soft pastel onepiece","onepiece",pick(a,3),null,null,"팔레트 컬러 적용")
        ));
        return rec;
    }

    private StyleRecommendation.GarmentItem item(String id, String name, String cat,
                                                 String hex, String fit, String neck, String reason) {
        StyleRecommendation.GarmentItem g = new StyleRecommendation.GarmentItem();
        g.setId(id); g.setName(name); g.setCategory(cat);
        g.setHex(hex); g.setFit(fit); g.setNeck(neck); g.setReason(reason);
        return g;
    }

    private String pick(StyleAnalysisResult a, int idx) {
        if (a.getPalette()!=null && a.getPalette().size()>idx) return a.getPalette().get(idx);
        return "#E6EEF7";
    }
}

