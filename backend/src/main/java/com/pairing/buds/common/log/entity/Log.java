package com.pairing.buds.common.log.entity;

import com.pairing.buds.common.basetime.CreateBaseTime;
import com.pairing.buds.common.response.Message;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "logs")
public class Log extends CreateBaseTime {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "log_id")
    private Long id;

    @Column(name = "source_description", nullable = false)
    private String sourceDescription;

    @Column(name = "completion", nullable = false, length = 10)
    private String completion = "SUCCESS";

    @Column(name = "response_time", nullable = false, updatable = false)
    private long responseTime;

    @Column(name = "status_message")
    private String statusMessage;

}
