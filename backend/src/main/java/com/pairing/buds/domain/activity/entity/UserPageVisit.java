package com.pairing.buds.domain.activity.entity;

import com.pairing.buds.common.basetime.CUBaseTime;
import com.pairing.buds.common.basetime.CreateBaseTime;
import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@IdClass(UserPageVisitId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "user_page_visits")
public class UserPageVisit extends CreateBaseTime {

    @Id
    @Column(name = "user_id")
    private Integer userId;

    @Id
    @Enumerated(EnumType.STRING)
    @Column(name = "page_name")
    private PageName pageName;
}
