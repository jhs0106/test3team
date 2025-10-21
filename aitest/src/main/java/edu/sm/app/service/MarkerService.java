package edu.sm.app.service;

import edu.sm.app.dto.Marker;
import edu.sm.app.repository.MarkerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MarkerService {
    private final MarkerRepository markerRepository;

    public void saveMarker(Marker marker) throws Exception {
        markerRepository.insert(marker);
    }

    public List<Marker> getAllMarkers() throws Exception {
        return markerRepository.findAll();
    }
}