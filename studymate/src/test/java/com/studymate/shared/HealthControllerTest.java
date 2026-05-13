package com.studymate.shared;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(controllers = HealthController.class)
public class HealthControllerTest {

    private final MockMvc mockMvc;

    @Autowired
    public HealthControllerTest(MockMvc mockMvc) {
        this.mockMvc = mockMvc;
    }

    @Test
    public void getHealth_returnsOkAndExpectedJson() throws Exception {
        mockMvc.perform(get("/api/health"))
            .andExpect(status().isOk())
            .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
            .andExpect(jsonPath("$.status").value("ok"))
            .andExpect(jsonPath("$.version").value("0.1.0"));
    }

}
