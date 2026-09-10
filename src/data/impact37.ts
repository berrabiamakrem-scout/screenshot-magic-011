// Official IMPACT 37 (أثر 37) strategic content — sourced from the official
// strategy document. Do not paraphrase or rewrite this terminology.

export const identity = {
  systemName: "منظومة أثر 37 لإدارة الاستراتيجية",
  organization: "الكشافة التونسية",
  committee: "اللجنة الوطنية للاستراتيجية والحوكمة",
  tagline: "نحو حركة شبابية ملهمة ومؤثرة",
  heroTitle: "مرحباً بك في منظومة أثر 37 لإدارة الاستراتيجية",
  heroSubtitle: "معاً نحو حركة شبابية ملهمة ومؤثرة ... من الفكرة إلى الأثر",
  heroOverlayLine1: "قادة اليوم...",
  heroOverlayLine2: "صنّاع الأثر...",
};

export const vision = {
  title: "الرؤية",
  text: "أن تكون الكشافة التونسية في أفق 2037: الحركة الشبابية الأكثر انتشارا، إلهاما وتأثيرا للفتية والشباب بتونس.",
};

export const mission = {
  title: "الرسالة",
  text: "ضمان أرضية عمل مشتركة بين مختلف هياكل الكشفية من خلال حوكمة رشيدة وموارد مالية كافية، وتوفير تجارب تعليمية مبتكرة تعمد على تعزيز المهارات الحياتية والاستدامة لضمان تمثيلية عادلة وشاملة لكافة الفئات ولفائدة الفتية والشباب من الجنسين، ودعم قدرات الشباب لاكتساب الشجاعة والثقة بالنفس لتولى القيادة المسؤولة، ملهمين ومؤثرين إيجابيا في أنفسهم ومجتمعاتهم في إطار الالتزام بأسس الحركة الكشفية.",
};

export const values = {
  title: "القيم",
  items: ["الوحدة", "الأداء", "الالتزام", "الفريق", "التطور"],
};

export type StrategicPath = {
  number: string;
  title: string;
  description: string;
  tone: "violet" | "navy" | "teal" | "green";
};

export const strategicPaths: StrategicPath[] = [
  {
    number: "01",
    title: "مسار التعليم المبتكر",
    description:
      "يعبر هذا المسار على تلبية احتياجات الفتية والشباب والمجتمع التونسي، بتوفير فرص التعلم عن طريق برامج تعليمية وتدريبية ملهمة، مبتكرة وجذابة، حتى تكون الحركة ممتعة محفزة ومتاحة للجميع.",
    tone: "violet",
  },
  {
    number: "02",
    title: "مسار منظمة ملائمة للهدف",
    description:
      "يتيح هذا المسار للمنظمة اعتماد الحوكمة الرشيدة لمختلف هياكلها، وتوفير الموارد المالية والبشرية لتحقيق أهدافها وضمان استدامتها وتكون قادرة على مزيد الانتشار والتوسع.",
    tone: "navy",
  },
  {
    number: "03",
    title: "مسار منظمة مؤثرة",
    description:
      "يؤكد هذا المسار أن المنظمة جهة فاعلة، تعبر عن قيم تربوية مجتمعية، ولتواصل المنظمة ترسيخ تلك القيم، ستعمل على دعم وتعزيز شبكة علاقات قوية مع مختلف الشركاء، وتعزيز الصورة الذهنية للمجتمع لإبراز الأثر الذي تحدثه المنظمة كشريك فاعل في المجتمع.",
    tone: "teal",
  },
  {
    number: "04",
    title: "مسار منظمة قادرة على التكيف",
    description:
      "كمنظمة تستجيب للمتغيرات المجتمعية والوطنية وواقع الشباب، يعزز هذا المسار قدرة الشباب على الابتكار والتحول الرقمي في جميع المجالات، بما يساهم في تحقيق استدامة البرامج وتعزيز تأثير المنظمة.",
    tone: "green",
  },
];

export type StrategicPriority = {
  number: string;
  title: string;
  path: string;
  icon:
    | "training"
    | "programme"
    | "governance"
    | "resources"
    | "media"
    | "partnerships"
    | "youth"
    | "sustainability";
  tone: "violet" | "navy" | "teal" | "green";
};

export const strategicPriorities: StrategicPriority[] = [
  {
    number: "01",
    title: "التدريب وبناء القدرات",
    path: "مسار التعليم المبتكر",
    icon: "training",
    tone: "violet",
  },
  {
    number: "02",
    title: "البرنامج الكشفي",
    path: "مسار التعليم المبتكر",
    icon: "programme",
    tone: "violet",
  },
  {
    number: "03",
    title: "الحوكمة والتطوير المؤسسي",
    path: "مسار منظمة ملائمة للهدف",
    icon: "governance",
    tone: "navy",
  },
  {
    number: "04",
    title: "الموارد (المالية والبشرية)",
    path: "مسار منظمة ملائمة للهدف",
    icon: "resources",
    tone: "navy",
  },
  {
    number: "05",
    title: "الإعلام والتسويق",
    path: "مسار منظمة مؤثرة",
    icon: "media",
    tone: "teal",
  },
  {
    number: "06",
    title: "الشراكات والعلاقات الخارجية",
    path: "مسار منظمة مؤثرة",
    icon: "partnerships",
    tone: "teal",
  },
  {
    number: "07",
    title: "الشباب",
    path: "مسار منظمة قادرة على التكيف",
    icon: "youth",
    tone: "green",
  },
  {
    number: "08",
    title: "الاستدامة",
    path: "مسار منظمة قادرة على التكيف",
    icon: "sustainability",
    tone: "green",
  },
];

export const phases = {
  current: "2025 – 2029",
  season: "2026 – 2027",
  horizon: "2025 – 2037",
};

export const contributionChain = [
  "نشاطك",
  "الهدف المرحلي",
  "الهدف الاستراتيجي",
  "الأولوية",
  "أثر 37",
];
